from django.apps import AppConfig

class ChatbotDiaryConfig(AppConfig):
    name = 'chatbot_diary'
    default_auto_field = 'django.db.models.BigAutoField'

    def ready(self):
        # 애플리케이션이 시작될 때 모델 초기화
        from kobert.kobert import initialize_kobert_models
        from kogpt2.kogpt2 import initialize_kogpt2_model
        initialize_kobert_models()
        initialize_kogpt2_model()
