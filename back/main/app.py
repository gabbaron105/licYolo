from flask_cors import CORS
from ultralytics import YOLO
from PIL import Image
import io
import os
from flask import Flask, request, jsonify, send_file
import cv2
from collections import defaultdict
from datetime import datetime
import numpy as np
import json
import logging
from data_routes import data_bp
from ignore_routes import ignore_bp
from vision_routes import vision_bp  # Importuj blueprint vision_bp
# Konfiguracja logowania
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

try:
    logging.debug("Ładowanie modelu YOLO...")
    model = YOLO("./yolo/yolo11l.pt")  # Zmień plik na właściwy plik modelu YOLO
    logging.debug("Model YOLO załadowany pomyślnie!")
except Exception as e:
    logging.error(f"Błąd ładowania modelu YOLO: {str(e)}")
    raise

app.register_blueprint(data_bp)
app.register_blueprint(ignore_bp)
app.register_blueprint(vision_bp)  # Zarejestruj blueprint vision_bp

@app.route('/')
def home():
    return "Flask server is running!"

def get_dominant_color(image, bbox):
    """
    :param image: Obraz w formacie numpy (np. klatka z OpenCV)
    :param bbox: Bounding box (słownik z 'xmin', 'ymin', 'xmax', 'ymax')
    :return: Kolor w formacie heksadecymalnym (np. '#RRGGBB')
    """
    xmin, ymin, xmax, ymax = bbox['xmin'], bbox['ymin'], bbox['xmax'], bbox['ymax']
    region = image[ymin:ymax, xmin:xmax]

    if region.size == 0:
        return "#000000"

    region = region.reshape(-1, 3)
    mean_color = np.mean(region, axis=0).astype(int)
    r, g, b = mean_color[2], mean_color[1], mean_color[0]
    return f"#{r:02x}{g:02x}{b:02x}"

@app.route('/detect_video', methods=['POST'])
def detect_video():
    data = request.get_json()
    video_url = data.get("video_url")
    ignored_classes = data.get("ignored_classes", [])

    if not video_url:
        return jsonify({"error": "No video URL provided"}), 400

    if video_url.startswith('file://'):
        video_url = video_url[7:]

    cap = cv2.VideoCapture(video_url)
    if not cap.isOpened():
        logging.error(f"Nie udało się otworzyć wideo: {video_url}")
        return jsonify({"error": "Failed to open video stream"}), 400

    frame_count = 0

    if not os.path.exists("wyniki"):
        os.makedirs("wyniki")

    with open("wyniki/general_detections.txt", "w", encoding="utf-8") as general_file:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            img_pil = Image.fromarray(img_rgb)

            results = model.predict(img_pil, verbose=False)  # Wykonanie predykcji
            detections = results[0].boxes.data.cpu().numpy()  # Wyniki jako numpy

            if ignored_classes:
                detections = [d for d in detections if int(d[5]) not in ignored_classes]

            if len(detections) > 0:
                detection_list = []

                for detection in detections:
                    xmin, ymin, xmax, ymax, confidence, class_id = map(int, detection[:6])
                    bbox = {"xmin": xmin, "ymin": ymin, "xmax": xmax, "ymax": ymax}
                    center_x = (xmin + xmax) // 2
                    center_y = (ymin + ymax) // 2
                    color = get_dominant_color(frame, bbox)

                    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    name = f"class_{class_id}"

                    detection_entry = {
                        "class": class_id,
                        "name": name,
                        "bbox": bbox,
                        "center": {
                            "x": center_x,
                            "y": center_y
                        },
                        "color": color,
                        "timestamp": timestamp
                    }
                    detection_list.append(detection_entry)

                general_file.write(f"Frame {frame_count}: {json.dumps(detection_list, ensure_ascii=False)}\n")
                general_file.flush()
                img_name = f"wyniki/frame_{frame_count}.jpg"
                cv2.imwrite(img_name, frame)

            frame_count += 1

    cap.release()
    return jsonify({"status": "Processing complete"}), 200



with open("class_names.json", "r", encoding="utf-8") as f:
    CLASS_NAMES = json.load(f)

def load_ignored_classes():
    try:
        if os.path.exists("./ignored_classes.json"):
            with open("ignored_classes.json", "r", encoding="utf-8") as f:
                return json.load(f).get("ignored_classes", [])
    except Exception as e:
        logging.error(f"Error loading ignored classes: {str(e)}")
    return []

@app.route('/upload_frame', methods=['POST'])
def upload_frame():
    if not request.data:
        logging.error("No data received")
        return jsonify({"error": "No data received"}), 400

    img_bytes = request.data
    ignored_classes = load_ignored_classes()

    try:
        img = Image.open(io.BytesIO(img_bytes))
        img_rgb = img.convert("RGB")
        img_np = np.array(img_rgb)

        results = model.predict(img_rgb, verbose=False)  # Wykonanie predykcji
        detections = results[0].boxes.data.cpu().numpy()  # Wyniki jako numpy

        detections = [d for d in detections if int(d[5]) not in ignored_classes]

        detection_list = []
        if not os.path.exists("wyniki"):
            os.makedirs("wyniki")

        frame_count = len([name for name in os.listdir("wyniki") if name.endswith(".jpg")]) + 1

        if len(detections) > 0:
            for detection in detections:
                xmin, ymin, xmax, ymax, confidence, class_id = map(int, detection[:6])
                bbox = {"xmin": xmin, "ymin": ymin, "xmax": xmax, "ymax": ymax}
                center_x = (xmin + xmax) // 2
                center_y = (ymin + ymax) // 2
                color = get_dominant_color(img_np, bbox)

                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                name = CLASS_NAMES.get(str(class_id), f"class_{class_id}")  # Pobranie nazwy z JSON

                detection_entry = {
                    "class": class_id,
                    "name": name,
                    "confidence": round(confidence, 2),
                    "bbox": bbox,
                    "center": {
                        "x": center_x,
                        "y": center_y
                    },
                    "color": color,
                    "timestamp": timestamp
                }
                detection_list.append(detection_entry)

            with open("wyniki/general_detections.txt", "a", encoding="utf-8") as f:
                f.write(f"Frame {frame_count}: {json.dumps(detection_list, ensure_ascii=False)}\n")

            img_name = f"wyniki/frame_{frame_count}.jpg"
            img.save(img_name)

        return jsonify({"detections": detection_list}), 200

    except Exception as e:
        logging.error(f"Error processing frame: {str(e)}")
        return jsonify({"error": str(e)}), 500



if __name__ == '__main__':
    CORS(app)
    app.run(host='0.0.0.0', debug=True)
