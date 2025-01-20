import torch

def test_model_loading():
    print("Loading YOLOv5 model...")
    model = torch.hub.load('ultralytics/yolov5', 'yolov5x6', pretrained=True)
    print("Model loaded successfully!")

if __name__ == "__main__":
    test_model_loading()
