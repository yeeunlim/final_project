import torch

class YOLOModel:
    def __init__(self, model_path):
        self.model = torch.hub.load('ultralytics/yolov5', 'custom', path=model_path)

    def predict(self, image):
        results = self.model(image)
        return results

    def extract_detections(self, results, img_width, img_height):
        detections = results.pandas().xyxy[0]
        detections_info = []

        for _, row in detections.iterrows():
            x1, y1, x2, y2 = float(row['xmin']), float(row['ymin']), float(row['xmax']), float(row['ymax'])
            conf, cls = float(row['confidence']), int(row['class'])
            width = x2 - x1
            height = y2 - y1
            center_x = x1 + width / 2
            center_y = y1 + height / 2
            cls_name = self.model.names[cls]

            detections_info.append({
                "class": cls_name,
                "x1": x1,
                "y1": y1,
                "x2": x2,
                "y2": y2,
                "width": width,
                "height": height,
                "center_x": center_x,
                "center_y": center_y,
                "confidence": conf
            })

        return detections_info
