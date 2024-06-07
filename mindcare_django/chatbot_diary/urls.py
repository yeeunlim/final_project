from django.urls import path
from .views import ChatbotResponseView, DiaryAnalysisView

app_name = 'chatbot_diary'


urlpatterns = [
    path('chatbot/', ChatbotResponseView.as_view(), name='chatbot-diary'),  # http://127.0.0.1:8000/api/chatbot_diary/chatbot/?s=입력문장
    path('diary_analysis/', DiaryAnalysisView.as_view(), name='diary-analysis'),
]