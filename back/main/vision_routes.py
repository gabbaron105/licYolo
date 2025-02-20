from flask import Blueprint, jsonify, request
import json
import os
from computer_vision import analyze_image, read_file

vision_bp = Blueprint('vision_bp', __name__)

@vision_bp.route('/analyze/<object_name>', methods=['GET'])
def analyze_object(object_name):
    data = read_file('./zgubione.txt')
    if object_name not in data:
        return jsonify({"error": "Object not found"}), 404

    object_data = data[object_name]
    frame_number = object_data.get("frame")
    image_path = f"./wyniki/frame_{frame_number}.jpg"

    result = analyze_image(image_path, f"{object_name}: {json.dumps(object_data)}")

    if "error" in result:
        return jsonify(result), 500
    else:
        # Sprawdzamy, czy 'summary' istnieje w wyniku. Jeśli nie, dodajemy pusty string.
        summary = result.get("summary", "")  # Kluczowa zmiana

        return jsonify({
            "summary": summary  # Zwracamy summary (nawet puste)
        }), 200