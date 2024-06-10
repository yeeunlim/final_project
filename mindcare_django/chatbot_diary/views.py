from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from kogpt2.kogpt2 import chatbot
from kobert.kobert import classify_emotion, classify_background, emotion_responses, emotion_category, background_category
from .models import DiaryEntry
from .serializers import DiaryEntrySerializer, MoodDataSerializer, MonthlyAnalysisSerializer
from django.contrib.auth import get_user_model
from rest_framework.permissions import AllowAny

class ChatbotResponseView(APIView):
    def get(self, request, *args, **kwargs):
        sentence = request.query_params.get("s", "")
        if not sentence:
            return Response({"error": "No input provided"}, status=status.HTTP_400_BAD_REQUEST)

        # 챗봇 응답 생성
        chatbot_response = chatbot(sentence)

        return Response({
            "chatbot_response": chatbot_response,
        }, status=status.HTTP_200_OK)
    
class DiaryAnalysisView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        diary_text = request.data.get("diary_text", "")
        entry_date = request.data.get("entry_date", "")
        if not diary_text:
            return Response({"error": "No diary text provided"}, status=status.HTTP_400_BAD_REQUEST)
        if not entry_date:
            return Response({"error": "No entry date provided"}, status=status.HTTP_400_BAD_REQUEST)
        
        # 줄바꿈 문자를 기준으로 문장 분리
        sentences = diary_text.split('\n')
        sentences = [sentence.strip() for sentence in sentences if sentence.strip()]

        if not sentences:
            return Response({"error": "No sentences found in diary text"}, status=status.HTTP_400_BAD_REQUEST)

        emotion_counts = {emotion: 0 for emotion in emotion_category.values()}
        background_counts = {background: 0 for background in background_category.values()}
        total_sentences = len(sentences)

        for sentence in sentences:
            emotion_probs, max_emotion = classify_emotion(sentence)
            background_probs, max_background = classify_background(sentence)
            emotion_counts[max_emotion] += 1
            background_counts[max_background] += 1

        # 퍼센트 계산 및 0%인 값 필터링
        emotion_distribution = {emotion: (count / total_sentences) * 100 for emotion, count in emotion_counts.items() if count > 0}
        background_distribution = {background: (count / total_sentences) * 100 for background, count in background_counts.items() if count > 0}

        most_felt_emotion = max(emotion_counts, key=emotion_counts.get)
        most_thought_background = max(background_counts, key=background_counts.get)
        response_message = emotion_responses.get(most_felt_emotion, "감정 분류 결과를 찾을 수 없습니다.")

        # 더미 유저 사용
        user = User.objects.get(username='dummy')

        diary_entry, created = DiaryEntry.objects.update_or_create(
            user=user,
            entry_date=entry_date,
            defaults={
                'diary_text': diary_text,
                'emotion_distribution': emotion_distribution,
                'background_distribution': background_distribution,
                'most_felt_emotion': most_felt_emotion,
                'most_thought_background': most_thought_background
            }
        )

        # 일기 데이터를 직렬화
        serializer = DiaryEntrySerializer(diary_entry)

        return Response({
            "id": serializer.data['id'],
            "emotion_distribution": emotion_distribution,
            "background_distribution": background_distribution,
            "most_felt_emotion": most_felt_emotion,
            "most_thought_background": most_thought_background,
            "response_message": response_message
        }, status=status.HTTP_200_OK)
    
    
User = get_user_model()

class DiaryEntryViewSet(viewsets.ModelViewSet):
    queryset = DiaryEntry.objects.all()
    serializer_class = DiaryEntrySerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated or user.username == 'dummy':
            user = User.objects.get(username='dummy')
        return DiaryEntry.objects.filter(user=user)
    
class MoodDataViewSet(viewsets.ViewSet):
    permission_classes = [AllowAny]

    def list(self, request):
        user = request.user
        if not user.is_authenticated or user.username == 'dummy':
            user = User.objects.get(username='dummy')
        
        entries = DiaryEntry.objects.filter(user=user)
        serializer = MoodDataSerializer(entries, many=True)
        
        # 데이터를 JSON 형식으로 변환
        mood_data = {entry['entry_date'].strftime('%Y-%m-%d'): entry['most_felt_emotion'] for entry in serializer.data}
        return Response(mood_data, status=status.HTTP_200_OK)

class MonthlyAnalysisViewSet(viewsets.ViewSet):
    permission_classes = [AllowAny]

    def list(self, request, year, month):
        user = request.user
        if not user.is_authenticated or user.username == 'dummy':
            user = User.objects.get(username='dummy')
        
        entries = DiaryEntry.objects.filter(
            user=user,
            entry_date__year=year,
            entry_date__month=month
        )
        serializer = MonthlyAnalysisSerializer(entries, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)