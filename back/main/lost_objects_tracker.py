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
        
        print(f"[LOG] Processing frame {frame_number}: {frame_data}")
        for obj in frame_data:
            obj_class = obj.get('name')
            obj_color = obj.get('color')

            if not obj_class or not obj_color:
                print("[WARNING] Object without 'name' or 'color' ignored.")
                continue

            matched = False
            for existing_name, existing_obj in self.objects.items():
                if existing_name.startswith(obj_class):  
                    if self.is_similar_color(existing_obj['color'], obj_color): 
                        print(f"[DEBUG] Match found: {existing_name} for color {obj_color}")
                        obj['frame'] = frame_number
                        self.objects[existing_name] = obj
                        matched = True
                        break

            if not matched:
                print(f"[DEBUG] No match for object {obj_class} with color {obj_color}")
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
    file_position = 0

    input_path = Path(input_file)
    output_path = Path(output_file)

    while True:
        try:
            if not input_path.exists():
                print(f"[WARNING] Input file {input_file} not found. Waiting...")
                time.sleep(10)
                continue

            with input_path.open('r') as file:
                file.seek(file_position)
                new_lines = file.readlines()
                file_position = file.tell()

            print(f"[LOG] Read {len(new_lines)} new lines from input file.")
            print(f"[LOG] Current file position: {file_position}")

            frame_number = 0
            for line in new_lines:
                frame_number += 1
                try:
                    if ': ' in line:
                        raw_data = line.strip().split(': ', 1)[1]
                        fixed_data = fix_json_line(raw_data) 
                        frame_data = json.loads(fixed_data)  
                        tracker.process_frame(frame_data, frame_number) 
                    else:
                        print(f"[WARNING] Invalid line format ignored: {line.strip()}")
                except (json.JSONDecodeError, IndexError) as e:
                    print(f"[ERROR] Error parsing line: {line.strip()} -> {e}")

            # Usuń plik jeśli istnieje
            if output_path.exists():
                try:
                    output_path.unlink()
                except Exception as e:
                    print(f"[ERROR] Failed to delete old output file: {e}")
                    continue  

            all_objects = tracker.get_all_objects()
            try:
                write_to_txt_file(output_file, all_objects)
            except Exception as e:
                print(f"[ERROR] Failed to write to output file: {e}")
                continue  

        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")

        time.sleep(2)


def ensure_directory_exists(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)


if __name__ == "__main__":
    output_file = './zgubione.txt'
    ensure_directory_exists(output_file)
    monitor_file('./wyniki/general_detections.txt', output_file, delta_color_threshold=100)
