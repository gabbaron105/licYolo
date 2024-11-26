import json
import time
import re
from pathlib import Path


class ObjectTracker:
    def __init__(self):
        self.objects = {}

    def process_frame(self, frame_data, frame_number):
        """
        Przetwarza dane z klatki: dodaje nowe obiekty lub aktualizuje istniejące.
        Dodaje informację o numerze klatki.
        """
        print(f"[LOG] Processing frame {frame_number}: {frame_data}")
        for obj in frame_data:
            obj_class = obj.get('name')
            if not obj_class:
                print("[WARNING] Object without a 'name' key ignored.")
                continue

            if obj.get('confidence', 0) > 0.65:
                # Dodaj informację o numerze klatki do danych obiektu
                obj['frame'] = frame_number
                self.objects[obj_class] = obj
                print(f"[LOG] Updated/added object: {obj_class} (frame: {frame_number})")
            else:
                print(f"[LOG] Object {obj_class} ignored due to low confidence.")

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
        print(f"[LOG] Fixed JSON line: {line.strip()}")
        return line
    except Exception as e:
        print(f"[ERROR] Error fixing line: {e}")
        raise

def write_to_txt_file(output_file, data):
    """
    Zapisuje dane do pliku tekstowego w formacie klucz: wartość.
    """
    try:
        with open(output_file, 'w') as f:
            for obj_class, obj_data in data.items():
                f.write(f"{obj_class}: {json.dumps(obj_data)}\n")
        print(f"[LOG] Updated output file: {output_file} with {len(data)} objects.")
    except Exception as e:
        print(f"[ERROR] Failed to write to {output_file}: {e}")



import os

def monitor_file(input_file, output_file):
    tracker = ObjectTracker()
    file_position = 0
    frame_number = 0  # Numer klatki

    while True:
        try:
            input_path = Path(input_file)

            if not input_path.exists():
                print(f"[WARNING] Input file {input_file} not found. Waiting...")
                time.sleep(2)
                continue

            # Odczytaj nowe linie z pliku wejściowego
            with input_path.open('r') as file:
                file.seek(file_position)
                new_lines = file.readlines()
                file_position = file.tell()

            print(f"[LOG] Read {len(new_lines)} new lines from input file.")

            # Przetwarzanie nowych danych
            for line in new_lines:
                frame_number += 1  # Każda linia odpowiada nowej klatce
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

            # Pobierz aktualny stan obiektów
            all_objects = tracker.get_all_objects()

            # Zapisz dane do pliku wyjściowego
            write_to_txt_file(output_file, all_objects)

        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")

        time.sleep(2)





if __name__ == "__main__":
    monitor_file('back/main/wyniki/general_detections.txt', 'object_updates.txt')
