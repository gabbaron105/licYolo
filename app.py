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






from datetime import datetime
import random

@app.route('/detect_video', methods=['POST'])
def detect_video():
    data = request.get_json()
    video_url = data.get("video_url")
    ignored_classes = data.get("ignored_classes", [])  # Lista klas do ignorowania

    if not video_url:
        return jsonify({"error": "No video URL provided"}), 400

    # Otwórz strumień wideo
    cap = cv2.VideoCapture(video_url)
    if not cap.isOpened():
        return jsonify({"error": "Failed to open video stream"}), 400

    frame_count = 0

    if not os.path.exists("wyniki"):
        os.makedirs("wyniki")

    model.conf = 0.1  # Obniżony próg pewności detekcji

    # Funkcja generująca losowy kolor
    def random_color():
        return f"#{random.randint(0, 255):02x}{random.randint(0, 255):02x}{random.randint(0, 255):02x}"

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
                    color = random_color()  # Losowy kolor dla każdego obiektu
                    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")  # Znacznik czasu
                    name = detection['name'] if 'name' in detection else f"class_{detection['class']}"  # Nazwa klasy

                    detection_entry = {
                        "class": detection['class'],
                        "name": name,
                        "confidence": round(detection['confidence'], 2),
                        "bbox": {
                            "xmin": int(detection['xmin']),
                            "ymin": int(detection['ymin']),
                            "xmax": int(detection['xmax']),
                            "ymax": int(detection['ymax']),
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
