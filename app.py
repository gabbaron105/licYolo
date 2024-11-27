import torch
from PIL import Image
import io
import os
from flask import Flask, request, jsonify
import cv2
from collections import defaultdict
from datetime import datetime
import random
from datetime import datetime
import random
import numpy as np







app = Flask(__name__)

# Załaduj model YOLOv5 (pretrained)
model = torch.hub.load('ultralytics/yolov5', 'yolov5m', pretrained=True)



@app.route('/')
def home():
    return "Flask server is running!"

@app.route('/predict', methods=['POST'])
def predict():
    # Sprawdź, czy w żądaniu są pliki
    if 'file' not in request.files and 'files' not in request.files:
        return jsonify({'error': 'No file(s) provided'}), 400
    
    # Lista na wyniki dla każdego obrazu
    all_detections = []

    # Obsługa przypadku pojedynczego obrazu
    if 'file' in request.files:
        files = [request.files['file']]  # Zmieniamy pojedynczy plik na listę z jednym elementem
    else:
        # Obsługa przypadku wielu obrazów
        files = request.files.getlist('files')

    # Przejdź przez wszystkie przesłane pliki (jedno- lub wielokrotne)
    for file in files:
        # Odczytaj plik jako bajty i przekształć w obraz PIL
        img_bytes = file.read()
        img = Image.open(io.BytesIO(img_bytes))

        # Wykonaj predykcję na obrazie
        results = model(img)
        detections = results.pandas().xyxy[0].to_dict(orient="records")

        # Dodaj wyniki dla obrazu do listy wyników
        all_detections.append({
            'filename': file.filename,  # Nazwa pliku
            'detections': detections    # Wykryte obiekty dla tego obrazu
        })

    # Zwróć wszystkie wykrycia jako JSON
    return jsonify(all_detections)




def get_dominant_color(image, bbox):
    """
    Oblicza dominujący kolor w regionie bounding box.
    :param image: Obraz w formacie numpy (np. klatka z OpenCV)
    :param bbox: Bounding box (słownik z 'xmin', 'ymin', 'xmax', 'ymax')
    :return: Kolor w formacie heksadecymalnym (np. '#RRGGBB')
    """
    xmin, ymin, xmax, ymax = bbox['xmin'], bbox['ymin'], bbox['xmax'], bbox['ymax']
    region = image[ymin:ymax, xmin:xmax]

    # Jeśli bounding box jest za mały, zwróć stały kolor
    if region.size == 0:
        return "#000000"  # Czarny jako fallback

    # Przekształć region na tablicę 2D z kolorami RGB
    region = region.reshape(-1, 3)

    # Oblicz średnią wartość koloru
    mean_color = np.mean(region, axis=0).astype(int)
    r, g, b = mean_color[2], mean_color[1], mean_color[0]  # OpenCV używa BGR
    return f"#{r:02x}{g:02x}{b:02x}"



@app.route('/detect_video', methods=['POST'])
def detect_video():
    data = request.get_json()
    video_url = data.get("video_url")
    ignored_classes = data.get("ignored_classes", [])  

    if not video_url:
        return jsonify({"error": "No video URL provided"}), 400

    # Otwórz strumień wideo
    cap = cv2.VideoCapture(video_url)
    if not cap.isOpened():
        return jsonify({"error": "Failed to open video stream"}), 400

    frame_count = 0

    if not os.path.exists("wyniki"):
        os.makedirs("wyniki")

    model.conf = 0.38  #pewności detekcji

   
    with open("wyniki/general_detections.txt", "w", encoding="utf-8") as general_file:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break  # Koniec wideo

            img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            img_pil = Image.fromarray(img_rgb)

            # Uzyskaj wyniki z modelu YOLO
            results = model(img_pil)
            detections = results.pandas().xyxy[0]

            # Debug: Wyświetl detekcje w terminalu
            print(f"Frame {frame_count}: Raw detections:\n{detections}")

            if ignored_classes:
                detections = detections[~detections['class'].isin(ignored_classes)]

            # Debug: Po filtrowaniu klas ignorowanych
            print(f"Frame {frame_count}: Filtered detections:\n{detections}")

            if not detections.empty:
                detection_list = []

                # Przetwarzanie każdej detekcji
                for _, detection in detections.iterrows():
                     # Oblicz środek (centroid) detekcji
                    xmin, ymin, xmax, ymax = int(detection['xmin']), int(detection['ymin']), int(detection['xmax']), int(detection['ymax'])
                    bbox = {"xmin": xmin, "ymin": ymin, "xmax": xmax, "ymax": ymax}
                    center_x = (xmin + xmax) // 2
                    center_y = (ymin + ymax) // 2

                    # Przykład koloru (możesz dodać logikę generowania koloru)
                    color = get_dominant_color(frame, bbox)

                    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")  # Znacznik czasu
                    name = detection['name'] if 'name' in detection else f"class_{detection['class']}"  # Nazwa klasy

                    detection_entry = {
                        "class": detection['class'],
                        "name": name,
                        "confidence": round(detection['confidence'], 2),
                        "bbox": {
                            "xmin": xmin,
                            "ymin": ymin,
                            "xmax": xmax,
                            "ymax": ymax,
                        },
                        "center": {  # Współrzędne środka
                            "x": center_x,
                            "y": center_y
                        },
                        "color": color,
                        "timestamp": timestamp
                    }
                    detection_list.append(detection_entry)

                # Zapisz detekcje do pliku tekstowego
                general_file.write(f"Frame {frame_count}: {detection_list}\n")
                general_file.flush()  # Wymuszenie zapisu na dysk
                print(f"Frame {frame_count}: Detekcje zapisane do pliku.")

                # Zapisz obraz z detekcjami w katalogu "wyniki"
                img_name = f"wyniki/frame_{frame_count}.jpg"
                cv2.imwrite(img_name, frame)
                print(f"Frame {frame_count}: Zapisano obraz: {img_name}")

            frame_count += 1

    cap.release()
    return jsonify({"status": "Processing complete"}), 200






if __name__ == '__main__':
    app.run(debug=True)
