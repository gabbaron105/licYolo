import math

def hex_to_rgb(hex_color):
    """
    Konwertuje kolor w formacie heksadecymalnym (#RRGGBB) na tuple RGB.
    """
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

def calculate_color_distance(color1, color2, threshold=50):
    """
    Oblicza odległość euklidesową między dwoma kolorami i sprawdza, czy są podobne w granicach progu.
    
    :param color1: Kolor w formacie heksadecymalnym (np. #FF5733).
    :param color2: Kolor w formacie heksadecymalnym (np. #FF5733).
    :param threshold: Maksymalna akceptowalna różnica między kolorami.
    :return: Słownik z odległością oraz informacją o podobieństwie.
    """
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    
    distance = math.sqrt((rgb1[0] - rgb2[0]) ** 2 +
                         (rgb1[1] - rgb2[1]) ** 2 +
                         (rgb1[2] - rgb2[2]) ** 2)
    
    similar = distance <= threshold
    
    return { 
        "color1": color1,
        "color2": color2,
        "distance": distance,
        "threshold": threshold,
        "similar": similar
    }

def compare_colors_interactively(color1=None, color2=None, threshold=None):
    """
    Pozwala interaktywnie podać kolory i próg do porównania.
    Jeśli argumenty są podane, używa ich zamiast prosić o dane od użytkownika.
    """
    if color1 is None:
        color1 = input("Podaj pierwszy kolor (#RRGGBB): ").strip()
    if color2 is None:
        color2 = input("Podaj drugi kolor (#RRGGBB): ").strip()
    if threshold is None:
        threshold = int(input("Podaj próg (threshold, np. 50): ").strip())
    
    result = calculate_color_distance(color1, color2, threshold)
    
    print(f"\nKolory do porównania: {result['color1']} i {result['color2']}")
    print(f"Odległość: {result['distance']:.2f}")
    print(f"Próg: {result['threshold']}")
    print(f"Podobne: {'TAK' if result['similar'] else 'NIE'}")

# Testy
if __name__ == "__main__":
    compare_colors_interactively(color1="#2203FF", color2="#e709ff", threshold=50)
    
