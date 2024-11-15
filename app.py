import torch
from PIL import Image
import io
import os
from flask import Flask, request, jsonify, Response
import cv2
import time


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


@app.route('/detect_video', methods=['POST'])
def detect_video():
    data = request.get_json()
    video_url = data.get("video_url")
    target_classes = data.get("target_classes")  # Classes of interest for detailed logging and frame saving
    ignored_classes = data.get("ignored_classes")  # Classes to completely ignore

    if not video_url:
        return jsonify({"error": "No video URL provided"}), 400
    if not target_classes or not isinstance(target_classes, list):
        return jsonify({"error": "Invalid or missing target classes. Provide a list of class IDs."}), 400
    if ignored_classes is not None and not isinstance(ignored_classes, list):
        return jsonify({"error": "Invalid ignored classes. Provide a list of class IDs."}), 400

    # Open video stream from the provided URL
    cap = cv2.VideoCapture(video_url)
    if not cap.isOpened():
        return jsonify({"error": "Failed to open video stream"}), 400

    fps = cap.get(cv2.CAP_PROP_FPS)
    frames_interval = int(fps // 4)  # Process frames at this interval for detections

    frame_count = 0

    # Open files for logging
    with open("wyniki/target_detections.txt", "a") as target_file, open("wyniki/general_detections.txt", "a") as general_file:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Process only every `frames_interval`-th frame
            if frame_count % frames_interval == 0:
                # Pass the current frame, target, and ignored classes for processing
                process_frame(frame, frame_count, target_file, general_file, target_classes, ignored_classes)

            frame_count += 1

    cap.release()
    return jsonify({"status": "Processing complete"}), 200


def process_frame(frame, frame_count, target_file, general_file, target_classes, ignored_classes=None):
    """
    Processes the detections for the given frame and writes them to separate files.
    Target classes trigger image saves and specific logging, while other non-ignored classes are logged elsewhere.

    Parameters:
    frame (numpy.ndarray): The frame from the video.
    frame_count (int): The current frame count.
    target_file (file): File handle for target class detections.
    general_file (file): File handle for general detections (non-target, non-ignored).
    target_classes (list): The classes of interest for detailed logging and frame saving.
    ignored_classes (list): Classes to ignore entirely.
    """
    # Convert the frame to RGB for YOLOv5
    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    img_pil = Image.fromarray(img_rgb)

    # Perform prediction
    results = model(img_pil)

    # Get detections as a DataFrame
    detections = results.pandas().xyxy[0]

    # Filter out ignored classes if specified
    if ignored_classes:
        detections = detections[~detections['class'].isin(ignored_classes)]

    # Separate detections into target and general categories
    target_detections = detections[detections['class'].isin(target_classes)]
    general_detections = detections[~detections['class'].isin(target_classes)]

    # Save and log target detections
    if not target_detections.empty:
        # Convert detections to a list of dictionaries
        target_list = target_detections.to_dict(orient="records")

        # Save the frame if target detections exist
        img_name = f"frame_{frame_count}_targets.jpg"
        Image.fromarray(img_rgb).save(img_name)
        print(f"Frame {frame_count}: Target classes detected and saved as {img_name}")

        # Log target detections to the target file
        target_file.write(f"Frame {frame_count}: {target_list}\n")

    # Log general detections (non-target, non-ignored) to the general file
    if not general_detections.empty:
        general_list = general_detections.to_dict(orient="records")
        print(f"Frame {frame_count}: General detections logged.")
        general_file.write(f"Frame {frame_count}: {general_list}\n")



if __name__ == '__main__':
    app.run(debug=True)
