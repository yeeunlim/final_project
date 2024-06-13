from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatbotResponseView, DiaryEntryViewSet, MonthlyAnalysisViewSet, MoodDataViewSet

app_name = 'chatbot_diary'

router = DefaultRouter()
router.register(r'diary_entries', DiaryEntryViewSet, basename='diaryentry')
router.register(r'mood_data', MoodDataViewSet, basename='mooddata')
router.register(r'monthly_analysis/(?P<year>\d{4})/(?P<month>\d{1,2})', MonthlyAnalysisViewSet, basename='monthlyanalysis')

urlpatterns = [
    path('chatbot/', ChatbotResponseView.as_view(), name='chatbot'),  # http://127.0.0.1:8000/api/chatbot_diary/chatbot/?s=입력문장
    path('', include(router.urls)),
]