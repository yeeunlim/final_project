from pathlib import Path
from django.apps import AppConfig
from kobert.kobert import initialize_kobert_models
from kogpt2.kogpt2 import initialize_kogpt2_model
import json
import global_vars

class ChatbotDiaryConfig(AppConfig):
    name = 'chatbot_diary'
    default_auto_field = 'django.db.models.BigAutoField'

    def ready(self):
        global global_vars

        # JSON 파일 로드
        global_vars.emotion_category = self.load_json("kobert/emotion_category.json")
        global_vars.background_category = self.load_json("kobert/background_category.json")

        # 모델 초기화
        initialize_kobert_models()
        initialize_kogpt2_model()

    def load_json(self, filename):
        path = Path(__file__).resolve().parent.parent / filename
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
