import json
import os
import google.generativeai as genai
from google.generativeai import types
from dotenv import load_dotenv

load_dotenv()

genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

def generate_prompt(text_line: str) -> str:
    """
    Tworzy prompt wymuszający krótką odpowiedź, podając przykłady oraz wymagając podsumowania po '&'.
    """
    try:
        label, json_data = text_line.split(": ", 1)
        data = json.loads(json_data)
    except Exception as e:
        raise ValueError(f"Błąd parsowania danych: {e}")

    object_name = data.get("name", "object")
    color = data.get("color", "unknown color")
    bbox = data.get("bbox", {})
    bbox_desc = (
        f"xmin: {bbox.get('xmin', '?')}, "
        f"ymin: {bbox.get('ymin', '?')}, "
        f"xmax: {bbox.get('xmax', '?')}, "
        f"ymax: {bbox.get('ymax', '?')}"
    )

    return (
        f"Describe the location of the {object_name} in *one concise sentence*. "  # Kluczowa zmiana
        f"The object is {color} and is positioned at {bbox_desc}. "
        "Specify its location relative to a clearly visible object in the scene.\n\n"

        "End your response with a *one-sentence summary* after the '&' symbol.\n"  # Kluczowa zmiana
        "For example:\n"
        f"- The {object_name} is next to the flowers on the table.\n"
        f"- The {object_name} is in front of the computer screen.\n"
        f"- The {object_name} is under the chair near the desk.\n\n"

        "Give an answer following this format. *Keep the answer extremely brief.*"  # Kluczowa zmiana
    )



from PIL import Image
import io
import google.generativeai as genai

from PIL import Image
import io
import google.generativeai as genai

from PIL import Image
import io
import google.generativeai as genai
from google.generativeai import types

def analyze_image(image_path: str, txt_line: str):
    """
    Analizuje obraz i generuje opis oraz prompt, ograniczając długość odpowiedzi.
    """
    try:
        with open(image_path, "rb") as image_file:
            image_bytes = image_file.read()

        image = Image.open(io.BytesIO(image_bytes))

        model = genai.GenerativeModel("gemini-1.5-flash")  # Lub "gemini-pro" jeśli dostępne

        # Ustawienia generacji - kluczowe zmiany:
        generation_config = types.GenerationConfig(
            max_output_tokens=30,  # Ograniczenie do ok. 30 tokenów (dostosuj)
            temperature=0.2       # Niższa temperatura dla krótszych odpowiedzi
        )

        response = model.generate_content(
            [
                {"mime_type": "image/jpeg", "data": image_bytes},
                "Describe this image concisely." # Dodano "concisely" do promptu bazowego
            ],
            generation_config=generation_config
        )

        description = response.text if response.text else "Brak opisu"
        prompt = generate_prompt(txt_line)

        # Dodajemy prompt do kontekstu dla modelu - to może pomóc w uzyskaniu lepszych odpowiedzi na prompt
        response_prompt = model.generate_content(
            [
                {"mime_type": "image/jpeg", "data": image_bytes},
                prompt
            ],
            generation_config=generation_config
        )

        final_answer = response_prompt.text if response_prompt.text else "Brak odpowiedzi na prompt"

        # Rozdzielenie odpowiedzi na opis i podsumowanie po '&'
        try:
            parts = final_answer.split("&")
            description_part = parts[0].strip()  # Pierwsza część (przed '&')
            summary_part = parts[1].strip() if len(parts) > 1 else ""  # Druga część (po '&') lub puste, jeśli brak '&'
        except IndexError:  # Obsługa sytuacji, gdy nie ma znaku '&'
            description_part = final_answer.strip()
            summary_part = ""

        result = {
            "description": description,
            "prompt": prompt,
            "answer": description_part,  # Tylko pierwsza część (przed '&')
            "summary": summary_part       # Dodajemy pole z podsumowaniem
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
                key = key.strip()
                value = value.strip()
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
            print("📍 Wygenerowany prompt:", result["prompt"])

if __name__ == "__main__":
    process_lost_objects()
