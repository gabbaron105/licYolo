import cv2
import os
import numpy as np
from datetime import datetime
import glob

class LostObjectsTracker:
    def __init__(self, max_lost_time, color_threshold=0.7):
        """
        Inicjalizacja trackera.
        :param max_lost_time: Maksymalny czas (w sekundach), przez jaki obiekt może być niewidoczny
        :param color_threshold: Próg podobieństwa kolorów (0-1), domyślnie 0.7
        """
        self.max_lost_time = max_lost_time
        self.color_threshold = color_threshold
        self.tracked_objects = {}
        self.lost_objects = []
        self.frame_count = 0

    def calculate_color_histogram(self, frame, coords):
        """
        Oblicza znormalizowany histogram kolorów dla obszaru obiektu.
        """
        xmin, ymin, xmax, ymax = map(int, coords)
        roi = frame[ymin:ymax, xmin:xmax]
        
        # Konwersja do HSV (bardziej odporny na zmiany oświetlenia)
        hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
        
        # Obliczenie histogramu dla każdego kanału HSV
        hist = cv2.calcHist([hsv_roi], [0, 1, 2], None, [8, 8, 8], 
                           [0, 180, 0, 256, 0, 256])
        
        # Normalizacja histogramu
        cv2.normalize(hist, hist, 0, 1, cv2.NORM_MINMAX)
        return hist

    def compare_histograms(self, hist1, hist2):
        """
        Porównuje dwa histogramy używając metody korelacji.
        Zwraca wartość podobieństwa w zakresie 0-1.
        """
        return cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)

    def remove_object_files(self, obj_id):
        """
        Usuwa pliki związane z danym obiektem z folderu zgubione_obiekty.
        """
        lost_objects_dir = os.path.join(os.getcwd(), "zgubione_obiekty")
        if not os.path.exists(lost_objects_dir):
            return

        pattern = os.path.join(lost_objects_dir, f"lost_object_{obj_id}_frame*")
        files_to_remove = glob.glob(pattern + ".jpg") + glob.glob(pattern + ".txt")
        
        for file_path in files_to_remove:
            try:
                os.remove(file_path)
                print(f"Usunięto plik: {file_path}")
            except Exception as e:
                print(f"Błąd podczas usuwania pliku {file_path}: {e}")

    def update_tracker(self, detections, frame_count, fps, current_frame):
        """
        Aktualizuje stan trackera na podstawie detekcji.
        """
        self.frame_count = frame_count
        current_objects = set()

        # Iteracja przez wszystkie aktualne detekcje
        for detection in detections:
            obj_class = detection['class']
            coords = (detection['xmin'], detection['ymin'], detection['xmax'], detection['ymax'])
            obj_id = f"{obj_class}_{coords}"

            # Oblicz histogram kolorów dla aktualnego obiektu
            current_hist = self.calculate_color_histogram(current_frame, coords)

            # Sprawdź, czy ten obiekt był wcześniej zgubiony
            for lost_obj in self.lost_objects[:]:  # Używamy kopii listy do iteracji
                if lost_obj["class"] == obj_class:
                    # Porównaj histogramy kolorów
                    similarity = self.compare_histograms(current_hist, lost_obj["color_hist"])
                    print(f"Podobieństwo kolorów dla {obj_class}: {similarity:.2f}")
                    
                    if similarity > self.color_threshold:
                        print(f"Znaleziono podobny obiekt klasy {obj_class} (podobieństwo: {similarity:.2f})")
                        self.remove_object_files(lost_obj["id"])
                        self.lost_objects.remove(lost_obj)

            # Zapisz obiekt z jego histogramem
            self.tracked_objects[obj_id] = {
                "last_seen_frame": frame_count,
                "last_seen_coords": coords,
                "class": obj_class,
                "confidence": detection.get('confidence', 0.0),
                "color_hist": current_hist
            }
            current_objects.add(obj_id)

        # Sprawdź, które obiekty "zgubiły się"
        lost_time_threshold = self.max_lost_time * fps
        for obj_id in list(self.tracked_objects.keys()):
            last_seen_frame = self.tracked_objects[obj_id]["last_seen_frame"]

            if frame_count - last_seen_frame > lost_time_threshold:
                lost_obj = {
                    "id": obj_id,
                    "last_seen_frame": last_seen_frame,
                    "last_seen_coords": self.tracked_objects[obj_id]["last_seen_coords"],
                    "class": self.tracked_objects[obj_id]["class"],
                    "confidence": self.tracked_objects[obj_id]["confidence"],
                    "color_hist": self.tracked_objects[obj_id]["color_hist"],
                    "lost_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                }
                self.lost_objects.append(lost_obj)
                del self.tracked_objects[obj_id]

    def get_lost_objects(self):
        """
        Pobiera listę zgubionych obiektów i resetuje listę.
        """
        lost_objects = self.lost_objects.copy()
        self.lost_objects = []
        return lost_objects

    def save_lost_frame(self, frame, obj):
        """
        Zapisuje pełną klatkę ze zgubionym obiektem.
        """
        lost_objects_dir = os.path.join(os.getcwd(), "zgubione_obiekty")
        os.makedirs(lost_objects_dir, exist_ok=True)

        base_filename = f"lost_object_{obj['id']}_frame{obj['last_seen_frame']}"
        image_path = os.path.join(lost_objects_dir, f"{base_filename}.jpg")
        info_path = os.path.join(lost_objects_dir, f"{base_filename}.txt")

        try:
            # Narysowanie prostokąta i etykiety
            frame_with_box = frame.copy()
            xmin, ymin, xmax, ymax = map(int, obj["last_seen_coords"])
            cv2.rectangle(frame_with_box, (xmin, ymin), (xmax, ymax), (0, 255, 0), 2)
            
            # Dodanie tekstu z klasą obiektu
            label = f"{obj['class']}"
            cv2.putText(frame_with_box, label, (xmin, ymin - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
            
            # Zapisanie obrazu
            cv2.imwrite(image_path, frame_with_box)
            
            # Zapisanie informacji do pliku txt
            info_text = f"""Informacje o zgubionym obiekcie:
=================================
ID obiektu: {obj['id']}
Klasa obiektu: {obj['class']}
Pewność detekcji: {obj['confidence']:.2f}
Numer klatki: {obj['last_seen_frame']}
Czas zgubienia: {obj['lost_time']}
Kolor: {obj['color_hist']}
Współrzędne obiektu: 
    X_min: {xmin}
    Y_min: {ymin}
    X_max: {xmax}
    Y_max: {ymax}
Wymiary obrazu: {frame.shape[1]}x{frame.shape[0]} pikseli
================================="""

            with open(info_path, 'w', encoding='utf-8') as f:
                f.write(info_text)

            print(f"Zapisano klatkę i informacje o zgubionym obiekcie:")
            print(f"Obraz: {image_path}")
            print(f"Informacje: {info_path}")

        except Exception as e:
            print(f"Błąd podczas zapisywania danych: {e}")