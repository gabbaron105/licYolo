from flask import Blueprint, jsonify, send_file
import os
import json

data_bp = Blueprint('data_bp', __name__)

def convert_to_json(file_path):
    converted_data = {}
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if ":" not in line:
                    continue  # Pomijamy linie bez dwukropka
                
                key, value = line.split(":", 1)  # Rozdzielamy pierwszy dwukropek
                key = key.strip()
                value = value.strip()
                
                try:
                    converted_data[key] = json.loads(value)
                except json.JSONDecodeError:
                    print(f"❌ Błąd parsowania JSON dla klucza: {key}")
        
        with open("zgubione.json", "w", encoding="utf-8") as json_file:
            json.dump(converted_data, json_file, indent=4, ensure_ascii=False)
        
        return converted_data
    except Exception as e:
        print(f"❌ Wystąpił błąd: {e}")
        return {}

def read_file():
    file_path = './zgubione.txt'
    json_path = './zgubione.json'
    
    if not os.path.exists(file_path):
        return {"error": "File not found"}
    
    convert_to_json(file_path)  # Konwertujemy plik przy każdym odczycie
    
    try:
        with open(json_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        return data
    except json.JSONDecodeError:
        return {"error": "Invalid JSON format in file"}
    except Exception as e:
        return {"error": str(e)}

@data_bp.route('/get-all', methods=['GET'])
def get_all():
    data = read_file()
    if "error" in data:
        return jsonify({"error": data["error"]}), 500
    return jsonify(data)

@data_bp.route('/get-by-class/<class_name>', methods=['GET'])
def get_by_class(class_name):
    data = read_file()
    if "error" in data:
        return jsonify({"error": data["error"]}), 500
    filtered_data = {key: value for key, value in data.items() if value["name"] == class_name}
    return jsonify(filtered_data)

@data_bp.route('/get-frame/<int:frame_number>', methods=['GET'])
def get_frame(frame_number):
    image_path = f"wyniki/frame_{frame_number}.jpg"
    if os.path.exists(image_path):
        return send_file(image_path, mimetype='image/jpeg')
    else:
        return jsonify({"error": "Frame not found"}), 404

@data_bp.route('/get-item-details/<string:item_id>', methods=['GET'])
def get_item_details(item_id):
    data = read_file()
    if "error" in data:
        return jsonify({"error": data["error"]}), 500
    item_details = data.get(item_id)
    if item_details:
        return jsonify(item_details)
    else:
        return jsonify({"error": "Item not found"}), 404
