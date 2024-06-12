from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import JSONParser
from rest_framework.permissions import IsAuthenticated
from .models import Drawing
from .serializers import DrawingSerializer
import boto3
import base64
import uuid
import torch
import json
import os
from PIL import Image as PILImage
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib import font_manager as fm
import requests
from io import BytesIO

class UploadDrawing(APIView):
    parser_classes = [JSONParser]
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        image_data = request.data['image']
        drawing_type = request.data['type']
        user = request.user

        # 타입 변환
        type_mapping = {
            '집을 그려주세요': 'house',
            '나무를 그려주세요': 'tree',
            '사람을 그려주세요': 'person'
        }
        drawing_type = type_mapping.get(drawing_type, drawing_type)

        # 이미지 디코딩
        image_data = base64.b64decode(image_data)
        file_name = f'{user.id}/{drawing_type}/{str(uuid.uuid4())}.png'
        local_file_path = f'/tmp/{file_name}'

        # 임시 파일로 저장
        os.makedirs(os.path.dirname(local_file_path), exist_ok=True)
        with open(local_file_path, 'wb') as f:
            f.write(image_data)

        # S3에 원본 이미지 업로드
        s3 = boto3.client('s3')
        s3.put_object(Bucket='mindcare-pj', Key=file_name, Body=image_data)
        image_url = f'https://mindcare-pj.s3.amazonaws.com/{file_name}'

        # Drawing 모델 저장
        drawing = Drawing.objects.create(
            user=user,
            type=drawing_type,  # 영어로 변환된 타입 저장
            image_url=image_url,
            result='진단 중입니다...'
        )
        serializer = DrawingSerializer(drawing)
        return Response(serializer.data)

class FinalizeDiagnosis(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        drawing_ids = request.data.get('drawingIds', [])
        user = request.user

        if not drawing_ids:
            return Response({'error': 'No drawing IDs provided'}, status=400)

        # 새로운 그림들만 필터링
        drawings = Drawing.objects.filter(id__in=drawing_ids, user=user)
        if len(drawings) != len(drawing_ids):
            return Response({'error': 'Not all drawings found'}, status=400)

        s3 = boto3.client('s3')
        model_paths = {
            'house': '../mindcare_django/yolov5/House/best.pt',
            'tree': '../mindcare_django/yolov5/Tree/best.pt',
            'person': '../mindcare_django/yolov5/Person/best.pt',
        }
        conditions_json_path = '../mindcare_django/yolov5/analysis_conditions_modify.json'
        stats_json_path = '../mindcare_django/yolov5/analysis_conditions_modify.json'

        analysis_results = []

        type_mapping = {
            '집을 그려주세요': 'house',
            '나무를 그려주세요': 'tree',
            '사람을 그려주세요': 'person'
        }

        for drawing in drawings:
            try:
                # 타입 변환
                drawing_type = type_mapping.get(drawing.type, drawing.type)
                model_path = model_paths.get(drawing_type)
                if model_path is None:
                    continue

                response = requests.get(drawing.image_url)
                img = PILImage.open(BytesIO(response.content))
                img_width, img_height = img.size

                model = torch.hub.load('ultralytics/yolov5', 'custom', path=model_path)
                results = self.predict(model, img)
                detections_info = self.extract_detections(results, model, img_width, img_height)
                analysis_conditions = self.load_analysis_conditions(conditions_json_path)
                class_stats = self.load_class_stats(stats_json_path)

                analysis_texts = self.analyze_detections(detections_info, analysis_conditions, class_stats)
                result_text = "\n".join(analysis_texts)

                result_img_url = self.visualize_and_upload(img, detections_info, model, user.id, drawing_type)

                # Drawing 모델 업데이트
                drawing.result = result_text
                drawing.result_image_url = result_img_url
                drawing.type = drawing_type  # 영어로 변환된 타입 저장
                drawing.save()

                analysis_results.append({
                    'id': drawing.id,
                    'type': drawing.type,
                    'result_image_url': result_img_url,
                    'result': result_text
                })
            except Exception as e:
                print(f"Error processing drawing {drawing.id}: {e}")

        # return Response(analysis_results)
        return Response(analysis_results, content_type="application/json; charset=utf-8")

    def predict(self, model, img):
        results = model(img)
        return results

    # !!!!!!! !!!!!!!!
    # def extract_detections(self, results, model, img_width, img_height):
    #     detections = results.xyxy[0].cpu().numpy()
    #     detections_info = []
    #     for *xyxy, conf, cls in detections:
    #         x1, y1, x2, y2 = xyxy
    #         width = x2 - x1
    #         height = y2 - y1
    #         center_x = x1 + width / 2
    #         center_y = y1 + height / 2
    #         cls_name = model.names[int(cls)]

    #         left_threshold = 0.3
    #         right_threshold = 0.7
    #         top_threshold = 0.3
    #         bottom_threshold = 0.7

    #         center_x_ratio = center_x / img_width
    #         center_y_ratio = center_y / img_height

    #         if center_x_ratio < left_threshold:
    #             x_position = "left"
    #         elif center_x_ratio > right_threshold:
    #             x_position = "right"
    #         else:
    #             x_position = "center"

    #         if center_y_ratio < top_threshold:
    #             y_position = "top"
    #         elif center_y_ratio > bottom_threshold:
    #             y_position = "bottom"
    #         else:
    #             y_position = "center"

    #         if x_position == "center" and y_position == "center":
    #             centered_position = "center"
    #         elif x_position == "center":
    #             centered_position = y_position
    #         elif y_position == "center":
    #             centered_position = x_position
    #         else:
    #             centered_position = f"{x_position}-{y_position}"

    #         detections_info.append({
    #             "class": cls_name,
    #             "x1": x1,
    #             "y1": y1,
    #             "x2": x2,
    #             "y2": y2,
    #             "width": width,
    #             "height": height,
    #             "center_x": center_x,
    #             "center_y": center_y,
    #             "width_ratio": width / img_width,
    #             "height_ratio": height / img_height,
    #             "center_x_ratio": center_x_ratio,
    #             "center_y_ratio": center_y_ratio,
    #             "confidence": conf,
    #             "centered_position": centered_position
    #         })
    #     return detections_info
    
    
    def extract_detections(self, results, model, img_width, img_height):
        try:
            detections = results.xyxy[0].cpu().numpy()
        except Exception as e:
            print(f"Error converting results to numpy array: {e}")
            return []

        detections_info = []
        for detection in detections:
            if len(detection) < 6:
                print(f"Invalid detection format: {detection}")
                continue

            try:
                x1, y1, x2, y2, conf, cls = detection[:6]
                width = x2 - x1
                height = y2 - y1
                center_x = x1 + width / 2
                center_y = y1 + height / 2
                cls_name = model.names[int(cls)]
            except Exception as e:
                print(f"Error extracting detection values: {e}")
                continue

            left_threshold = 0.3
            right_threshold = 0.7
            top_threshold = 0.3
            bottom_threshold = 0.7

            center_x_ratio = center_x / img_width
            center_y_ratio = center_y / img_height

            if center_x_ratio < left_threshold:
                x_position = "left"
            elif center_x_ratio > right_threshold:
                x_position = "right"
            else:
                x_position = "center"

            if center_y_ratio < top_threshold:
                y_position = "top"
            elif center_y_ratio > bottom_threshold:
                y_position = "bottom"
            else:
                y_position = "center"

            if x_position == "center" and y_position == "center":
                centered_position = "center"
            elif x_position == "center":
                centered_position = y_position
            elif y_position == "center":
                centered_position = x_position
            else:
                centered_position = f"{x_position}-{y_position}"

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
                "width_ratio": width / img_width,
                "height_ratio": height / img_height,
                "center_x_ratio": center_x_ratio,
                "center_y_ratio": center_y_ratio,
                "confidence": conf,
                "centered_position": centered_position
            })
        return detections_info


    def load_analysis_conditions(self, json_path):
        with open(json_path, 'r', encoding='utf-8') as f:
            conditions = json.load(f)
        return conditions

    def load_class_stats(self, json_path):
        with open(json_path, 'r', encoding='utf-8') as f:
            stats = json.load(f)
        return stats

    def analyze_detections(self, detections_info, analysis_conditions, class_stats):
        analysis_texts = set()
        class_counts = {}

        for info in detections_info:
            cls_name = info["class"]
            if cls_name in class_counts:
                class_counts[cls_name] += 1
            else:
                class_counts[cls_name] = 1

        for info in detections_info:
            cls_name = info["class"]
            analysis = set()

            for condition in analysis_conditions:
                if condition["class"] == cls_name:
                    for cond in condition["conditions"]:
                        check_function = eval(cond["check"])
                        args = [info]
                        if "count" in check_function.__code__.co_varnames:
                            args.append(class_counts[cls_name])
                        if "class_counts" in check_function.__code__.co_varnames:
                            args.append(class_counts)
                        if "mean_w" in check_function.__code__.co_varnames:
                            args.append(class_stats[cls_name]["mean_w"])
                        if "std_w" in check_function.__code__.co_varnames:
                            args.append(class_stats[cls_name]["std_w"])
                        if "mean_h" in check_function.__code__.co_varnames:
                            args.append(class_stats[cls_name]["mean_h"])
                        if "std_h" in check_function.__code__.co_varnames:
                            args.append(class_stats[cls_name]["std_h"])

                        expected_args = check_function.__code__.co_varnames[:check_function.__code__.co_argcount]
                        args_to_pass = [arg for name, arg in zip(expected_args, args) if name in expected_args]
                        if check_function(*args_to_pass):
                            analysis.add(cond["result"])

            if analysis:
                analysis_text = f"{cls_name}: {' '.join(analysis)}"
                analysis_texts.add(analysis_text)

        analysis_list = list(analysis_texts)

        if len(analysis_list) <= 2:
            if len(analysis_list) == 0:
                additional_text = "당신의 그림에는 깊은 평온함이 느껴집니다. 이는 당신이 내면의 균형을 잘 유지하고 있음을 나타냅니다. 이 고요한 상태를 소중히 여기세요."
            elif len(analysis_list) == 1:
                additional_text = "당신의 그림에는 단순함과 명확성이 돋보입니다. 이는 당신이 현재 심리적으로 안정되어 있으며, 생각이 명료함을 보여줍니다. 이 상태를 유지하면서 앞으로 나아가세요."
            else:
                additional_text = "당신의 그림은 조화와 균형을 보여줍니다. 이는 당신의 내면이 안정되어 있으며, 다양한 측면이 조화롭게 공존하고 있음을 나타냅니다. 이 안정감을 주위 사람들과 나누어 그들에게 긍정적인 영향을 주세요."
        elif len(analysis_list) == 3:
            additional_text = "당신의 그림에는 다양한 요소들이 나타납니다. 이는 복잡한 내면 상태를 반영할 수 있지만, 동시에 풍부한 감정과 생각을 가지고 있다는 증거이기도 합니다. 이 다양성을 인정하고 받아들이세요."
        elif len(analysis_list) == 4:
            additional_text = "당신의 그림에는 꽤 많은 요소들이 있네요. 이는 당신의 마음이 여러 가지 생각과 감정으로 가득 차 있음을 나타낼 수 있어요. 때로는 이런 복잡성이 부담이 될 수 있습니다. 잠시 멈추어 각 요소를 이해하고 정리해보는 것이 어떨까요?"
        elif len(analysis_list) == 5:
            additional_text = "당신의 그림에는 상당히 많은 요소들이 나타나고 있어요. 괜찮으신가요? 이는 당신의 마음에 많은 생각과 감정이 공존하고 있음을 나타낼 수 있습니다. 이러한 복잡성은 창의성과 깊이의 표시일 수도 있지만, 동시에 내면의 혼란을 의미할 수도 있어요. 잠시 시간을 내어 이 요소들을 차분히 살펴보시는 게 어떨까요?"
        else:
            base_text = "당신의 그림에는 매우 많은 요소들이 나타나고 있습니다. 이는 당신의 마음이 매우 복잡하고 분주한 상태임을 나타낼 수 있어요. 이런 상태는 창의성의 폭발이나 깊은 통찰력의 징후일 수 있지만, 동시에 과도한 스트레스나 내면의 갈등을 반영할 수도 있습니다."
            if len(analysis_list) >= 8:
                additional_text = base_text + " 솔직히 말씀드리면, 이 정도로 복잡한 그림은 상당한 심리적 압박감을 나타낼 수 있어 걱정이 됩니다. 전문가와 상담을 받아보시는 것이 좋을 것 같아요. 그들은 당신의 내면을 더 깊이 이해하고 정리하는 데 도움을 줄 수 있습니다."
            else:
                additional_text = base_text + " 전문적인 심리 상담을 받아보시는 것이 도움이 될 수 있습니다. 상담사는 이 복잡한 요소들을 해석하고, 당신이 내면의 균형을 되찾는 데 도움을 줄 수 있어요. 이는 자기 이해와 성장의 기회가 될 수 있습니다."

        analysis_list.insert(0, additional_text)
        return analysis_list

    def visualize_and_upload(self, img, detections_info, model, user_id, drawing_type):
        plt.figure(figsize=(10, 10))
        plt.imshow(img)
        ax = plt.gca()

        for detection in detections_info:
            x1, y1, x2, y2 = detection['x1'], detection['y1'], detection['x2'], detection['y2']
            width = x2 - x1
            height = y2 - y1
            class_name = detection["class"]
            confidence = detection["confidence"]

            rect = patches.Rectangle((x1, y1), width, height, linewidth=2, edgecolor='red', facecolor='none')
            ax.add_patch(rect)

            plt.text(x1, y1, f'{class_name} {confidence:.2f}', bbox=dict(facecolor='yellow', alpha=0.5), fontproperties=fm.FontProperties(fname='/System/Library/Fonts/Supplemental/AppleGothic.ttf'))

        plt.axis('off')
        save_path = f"/tmp/{uuid.uuid4()}_detection_results_with_labels.png"
        plt.savefig(save_path, bbox_inches='tight', pad_inches=0.1)
        plt.close()

        # S3에 결과 이미지 업로드
        s3 = boto3.client('s3')
        result_file_name = f'results/{user_id}/{drawing_type}/{uuid.uuid4()}_result.png'
        with open(save_path, 'rb') as result_file:
            s3.put_object(Bucket='mindcare-pj', Key=result_file_name, Body=result_file)
        
        result_img_url = f'https://mindcare-pj.s3.amazonaws.com/{result_file_name}'
        return result_img_url


