import json
import time
import re
from pathlib import Path
import math


class ObjectTracker:
    def __init__(self, delta_color_threshold=50):
        """
        Inicjalizuje tracker z limitem podobieństwa kolorów.
        :param delta_color_threshold: Maksymalna akceptowalna różnica między kolorami.
        """
        self.objects = {}  # Słownik: { "dog_1": {...}, "dog_2": {...} }
        self.delta_color_threshold = delta_color_threshold

    @staticmethod
    def hex_to_rgb(hex_color):
        """
        Konwertuje kolor w formacie heksadecymalnym (#RRGGBB) na tuple RGB.
        """
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

    @staticmethod
    def color_distance(color1, color2):
        """
        Oblicza różnicę euklidesową między dwoma kolorami w przestrzeni RGB.
        """
        r1, g1, b1 = ObjectTracker.hex_to_rgb(color1)
        r2, g2, b2 = ObjectTracker.hex_to_rgb(color2)
        return math.sqrt((r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2)

    def is_similar_color(self, color1, color2):
       
        #Sprawdza, czy dwa kolory są podobne w granicach tolerancji.
        
        return self.color_distance(color1, color2) <= self.delta_color_threshold

    def generate_object_name(self, obj_class):
        """
        Generuje unikalną nazwę dla obiektu, np. 'dog_1', 'dog_2'.
        """
        existing_keys = [key for key in self.objects.keys() if key.startswith(obj_class)]
        return f"{obj_class}_{len(existing_keys) + 1}"

    def process_frame(self, frame_data, frame_number):
        """
        Przetwarza dane z klatki, uwzględniając klasę i kolor z tolerancją.
        """
        print(f"[LOG] Processing frame {frame_number}: {frame_data}")
        for obj in frame_data:
            obj_class = obj.get('name')
            obj_color = obj.get('color')

            if not obj_class or not obj_color:
                print("[WARNING] Object without 'name' or 'color' ignored.")
                continue

            # Sprawdź wszystkie istniejące obiekty tej klasy
            matched = False
            for existing_name, existing_obj in self.objects.items():
                if existing_name.startswith(obj_class):  # Dopasowanie klasy
                    if self.is_similar_color(existing_obj['color'], obj_color):  # Dopasowanie koloru
                        # Aktualizuj istniejący obiekt
                        obj['frame'] = frame_number
                        self.objects[existing_name] = obj
                        print(f"[LOG] Updated object: {existing_name} (frame: {frame_number}, color similar)")
                        matched = True
                        break

            # Jeśli nie znaleziono pasującego obiektu, dodaj nowy
            if not matched:
                new_object_name = self.generate_object_name(obj_class)
                obj['frame'] = frame_number
                self.objects[new_object_name] = obj
                print(f"[LOG] Added new object: {new_object_name} (frame: {frame_number})")

    def get_all_objects(self):
        """
        Zwraca aktualny stan wszystkich obiektów.
        """
        print(f"[LOG] Current state of objects: {self.objects}")
        return self.objects


def fix_json_line(line):
    """
    Naprawia błędnie sformatowany JSON:
    - Dodaje podwójne cudzysłowy wokół kluczy.
    - Zamienia pojedyncze cudzysłowy na podwójne.
    """
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


def monitor_file(input_file, output_file, delta_color_threshold=50):
    """
    Monitoruje plik wejściowy i zapisuje dane do pliku wynikowego.
    """
    tracker = ObjectTracker(delta_color_threshold=delta_color_threshold)
    file_position = 0

    input_path = Path(input_file)
    output_path = Path(output_file)

    while True:
        try:
            # Sprawdź, czy plik wejściowy istnieje
            if not input_path.exists():
                print(f"[WARNING] Input file {input_file} not found. Waiting...")
                time.sleep(10)
                continue

            # Czytaj nowe linie z pliku wejściowego
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
                        fixed_data = fix_json_line(raw_data)  # Napraw dane
                        frame_data = json.loads(fixed_data)  # Parsowanie JSON
                        tracker.process_frame(frame_data, frame_number)  # Aktualizuj stan
                    else:
                        print(f"[WARNING] Invalid line format ignored: {line.strip()}")
                except (json.JSONDecodeError, IndexError) as e:
                    print(f"[ERROR] Error parsing line: {line.strip()} -> {e}")

            # Usuń plik wynikowy, jeśli istnieje
            if output_path.exists():
                try:
                    output_path.unlink()
                except Exception as e:
                    print(f"[ERROR] Failed to delete old output file: {e}")
                    continue  # Kontynuuj pętlę, jeśli usuwanie nie powiedzie się

            # Zapisz pełny stan obiektów do nowego pliku
            all_objects = tracker.get_all_objects()
            try:
                write_to_txt_file(output_file, all_objects)
            except Exception as e:
                print(f"[ERROR] Failed to write to output file: {e}")
                continue  # Pomijamy tę iterację

        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")

        # Oczekuj na nowe dane
        time.sleep(2)


if __name__ == "__main__":
    monitor_file('back/main/wyniki/general_detections.txt', 'back/main/zgubione.txt')
