import json
import time
import re
from pathlib import Path
import math
import os


class ObjectTracker:
    def __init__(self, delta_color_threshold):
        """
        Inicjalizuje tracker z limitem podobieństwa kolorów.
        :param delta_color_threshold: Maksymalna akceptowalna różnica między kolorami.
        """
        self.objects = {}  
        self.delta_color_threshold = delta_color_threshold

    @staticmethod
    def hex_to_rgb(hex_color):
        """
        Konwertuj kolor
        """
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

    @staticmethod
    def color_distance(color1, color2):
        
        r1, g1, b1 = ObjectTracker.hex_to_rgb(color1)
        r2, g2, b2 = ObjectTracker.hex_to_rgb(color2)
        return math.sqrt((r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2)

    def is_similar_color(self, color1, color2):
        distance = self.color_distance(color1, color2)
        print(f"[DEBUG] Comparing {color1} and {color2} - Distance: {distance}, Threshold: {self.delta_color_threshold}")
        return distance <= self.delta_color_threshold


    def generate_object_name(self, obj_class):
        
        existing_keys = [key for key in self.objects.keys() if key.startswith(obj_class)]
        return f"{obj_class}_{len(existing_keys) + 1}"

    def process_frame(self, frame_data, frame_number):
        
        #print(f"[LOG] Processing frame {frame_number}: {frame_data}")
        for obj in frame_data:
            obj_class = obj.get('name')
            obj_color = obj.get('color')

            if not obj_class or not obj_color:
                #print("[WARNING] Object without 'name' or 'color' ignored.")
                continue

            matched = False
            for existing_name, existing_obj in self.objects.items():
                if existing_name.startswith(obj_class):  
                    if self.is_similar_color(existing_obj['color'], obj_color): 
                        #print(f"[DEBUG] Match found: {existing_name} for color {obj_color}")
                        obj['frame'] = frame_number
                        self.objects[existing_name] = obj
                        matched = True
                        break

            if not matched:
                #print(f"[DEBUG] No match for object {obj_class} with color {obj_color}")
                new_object_name = self.generate_object_name(obj_class)
                obj['frame'] = frame_number
                self.objects[new_object_name] = obj


    def get_all_objects(self):
        """
        Zwraca aktualny stan wszystkich obiektów.
        """
        print(f"[LOG] Current state of objects: {self.objects}")
        return self.objects


def fix_json_line(line):

    try:
        print(f"[LOG] Original line before fixing: {line.strip()}")
        line = re.sub(r"(?<!\\)'", '"', line)
        line = re.sub(r'(\b[a-zA-Z_]\w*\b):', r'"\1":', line)
        return line
    except Exception as e:
        print(f"[ERROR] Error fixing line: {e}")
        raise


def write_to_txt_file(output_file, data):
    """
    Zapisuje dane do pliku tekstowego w formacie klucz: wartość.
    """
    try:
        print(f"[LOG] Writing data to {output_file}")
        with open(output_file, 'w') as f:
            for obj_name, obj_data in data.items():
                f.write(f"{obj_name}: {json.dumps(obj_data)}\n")
        print(f"[LOG] Successfully wrote data to {output_file}")
    except Exception as e:
        print(f"[ERROR] Failed to write to {output_file}: {e}")


def monitor_file(input_file, output_file, delta_color_threshold):
    tracker = ObjectTracker(delta_color_threshold=delta_color_threshold)

    input_path = Path(input_file)
    output_path = Path(output_file)

    while True:
        try:
            if not input_path.exists():
                print(f"[WARNING] Input file {input_file} not found. Waiting...")
                time.sleep(10)
                continue

            with input_path.open('r') as file:
                lines = file.readlines()  # ZAWSZE czytamy cały plik od początku

            #print(f"[LOG] Read {len(lines)} lines from input file.")

            for line in lines:
                try:
                    if ': ' in line:
                        frame_info, raw_data = line.strip().split(': ', 1)
                        
                        # Usuwamy "Frame " i zamieniamy na liczbę
                        frame_number = int(frame_info.replace("Frame ", ""))  

                        fixed_data = fix_json_line(raw_data)
                        frame_data = json.loads(fixed_data)
                        tracker.process_frame(frame_data, frame_number)  # Przekazujemy poprawny frame_number
                    else:
                        print(f"[WARNING] Invalid line format ignored: {line.strip()}")
                except (json.JSONDecodeError, IndexError, ValueError) as e:
                    print(f"[ERROR] Error parsing line: {line.strip()} -> {e}")


            if output_path.exists():
                try:
                    output_path.unlink()  # Usuwamy stary plik wyjściowy
                except Exception as e:
                    print(f"[ERROR] Failed to delete old output file: {e}")
                    continue  

            all_objects = tracker.get_all_objects()
            try:
                write_to_txt_file(output_file, all_objects)

                # Pobierz aktualnie używane klatki
                used_frames = {obj["frame"] for obj in all_objects.values() if "frame" in obj}                
                clean_unused_images('./wyniki/', used_frames, tracker)  # Przekazujemy tracker, żeby sprawdzać obiekty
            except Exception as e:
                print(f"[ERROR] Failed to write to output file: {e}")
                continue  

        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")

        time.sleep(2)  # Oczekiwanie przed kolejnym odczytem

import os

def clean_unused_images(image_folder, used_frames, object_tracker):
    """
    Usuwa obrazy `./wyniki/frame_x`, jeśli klatka nie jest już używana, 
    jest starsza niż 10 klatek od najnowszej i nie zawiera żadnych obiektów.

    :param image_folder: Folder, w którym znajdują się obrazy.
    :param used_frames: Zestaw klatek, które powinny pozostać.
    :param object_tracker: Instancja `ObjectTracker`, do sprawdzenia obiektów na klatkach.
    """
    try:
        if not os.path.exists(image_folder):
            print(f"[WARNING] Folder {image_folder} nie istnieje. Pomijam czyszczenie.")
            return

        if not used_frames:
            print(f"[WARNING] Brak klatek w `used_frames`. Pomijam czyszczenie.")
            return

        max_used_frame = max(used_frames)  # Najnowsza używana klatka
        safe_threshold = max_used_frame - 10  # Nie usuwamy klatek nowszych niż (max - 10)

        print(f"[LOG] Maksymalna używana klatka: {max_used_frame}, Usuwamy starsze niż: {safe_threshold}")

        for frame_number in range(safe_threshold):  # Sprawdzamy tylko starsze klatki
            frame_path = os.path.join(image_folder, f"frame_{frame_number}.jpg")

            # Sprawdź, czy na tej klatce są jakieś obiekty
            has_objects = any(obj["frame"] == frame_number for obj in object_tracker.objects.values())

            # Usuwamy, jeśli:
            # 1. Nie ma jej w `used_frames`
            # 2. Jest starsza niż `safe_threshold`
            # 3. Nie zawiera obiektów
            if frame_number not in used_frames and not has_objects:
                if os.path.exists(frame_path):
                    try:
                        os.remove(frame_path)
                        print(f"[LOG] Usunięto zbędny obraz: {frame_path}")
                    except Exception as e:
                        print(f"[ERROR] Nie udało się usunąć {frame_path}: {e}")
                else:
                    print(f"[WARNING] Plik {frame_path} nie istnieje.")
            else:
                print(f"[DEBUG] Nie usuwam frame_{frame_number} - "
                      f"{'jest w used_frames' if frame_number in used_frames else ''} "
                      f"{'ma obiekty' if has_objects else ''}".strip())

    except Exception as e:
        print(f"[ERROR] Błąd podczas czyszczenia obrazów: {e}")



def ensure_directory_exists(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)


if __name__ == "__main__":
    output_file = './zgubione.txt'
    ensure_directory_exists(output_file)
    monitor_file('./wyniki/general_detections.txt', output_file, delta_color_threshold=100)
