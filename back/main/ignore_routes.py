from flask import Blueprint, jsonify, request
import json
import os

ignore_bp = Blueprint('ignore_bp', __name__)

@ignore_bp.route('/view-ignored-classes', methods=['GET'])
def view_ignored_classes():
    try:
        with open('./ignored_classes.json', 'r', encoding='utf-8') as file:
            data = json.load(file)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@ignore_bp.route('/edit-ignored-classes', methods=['POST'])
def edit_ignored_classes():
    try:
        new_classes = request.json.get('new_classes', [])
        remove_classes = request.json.get('remove_classes', [])

        if not os.path.exists('./ignored_classes.json'):
            data = {"ignored_classes": []}
        else:
            with open('./ignored_classes.json', 'r', encoding='utf-8') as file:
                data = json.load(file)

        ignored_classes = set(data.get('ignored_classes', []))

        # Add new classes
        ignored_classes.update(new_classes)
        # Remove specified classes
        ignored_classes.difference_update(remove_classes)

        data['ignored_classes'] = list(ignored_classes)

        with open('./ignored_classes.json', 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=4, ensure_ascii=False)

        return jsonify({"message": "Ignored classes updated successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
