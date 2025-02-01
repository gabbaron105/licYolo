import json
import os
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials
from dotenv import load_dotenv

load_dotenv()

AZURE_ENDPOINT = os.getenv("AZURE_ENDPOINT")
AZURE_API_KEY = os.getenv("AZURE_API_KEY")

client = ComputerVisionClient(AZURE_ENDPOINT, CognitiveServicesCredentials(AZURE_API_KEY))

def generate_prompt(text_line: str) -> str:
    """
    Tworzy prompt opisujący lokalizację obiektu na podstawie jego bbox.
    """
    try:
        label, json_data = text_line.split(": ", 1)
        data = json.loads(json_data)
    except Exception as e:
        raise ValueError(f"Błąd parsowania danych: {e}")

    object_name = data.get("name", "obiekt")
    colr = data.get("color", "obiekt")
    bbox = data.get("bbox", {})
    bbox_desc = (
        f"xmin: {bbox.get('xmin', '?')}, "
        f"ymin: {bbox.get('ymin', '?')}, "
        f"xmax: {bbox.get('xmax', '?')}, "
        f"ymax: {bbox.get('ymax', '?')}"
    )

    return (
        f"Please tell me where the {object_name} is located, "
        f"knowing that it has this color: {colr} and is in the following location: {bbox_desc}. "
        "Describe it as if you were explaining it to someone who lost this object:"
    )


def analyze_image(image_path: str, txt_line: str):
    """
    Pobiera opis sceny i tagi z Azure, a następnie generuje prompt.
    """
    try:
        with open(image_path, "rb") as image_file:
            analysis = client.analyze_image_in_stream(
                image_file, visual_features=["Description", "Tags"]
            )

        description = analysis.description.captions[0].text if analysis.description.captions else "Brak opisu"
        tags = [tag.name for tag in analysis.tags]

        prompt = generate_prompt(txt_line)

        result = {
            "description": description,
            "tags": tags,
            "prompt": prompt
        }

        return result

    except Exception as e:
        return {"error": str(e)}

def read_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            data = {}
            for line in file:
                if ":" not in line:
                    continue
                key, value = line.split(":", 1)
                key is key.strip()
                value is value.strip()
                data[key] = json.loads(value)
            return data
    except Exception as e:
        print(f"❌ Wystąpił błąd: {e}")
        return {}

def process_lost_objects():
    data = read_file('./zgubione.txt')
    for key, value in data.items():
        frame_number = value.get("frame")
        image_path = f"./wyniki/frame_{frame_number}.jpg"
        result = analyze_image(image_path, f"{key}: {json.dumps(value)}")
        if "error" in result:
            print("❌ Błąd:", result["error"])
        else:
            print("🔹 Opis obrazu:", result["description"])
            print("🏷️ Tagi:", ", ".join(result["tags"]))
            print("📍 Wygenerowany prompt:", result["prompt"])

if __name__ == "__main__":
    process_lost_objects()
