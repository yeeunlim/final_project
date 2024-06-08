from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from kogpt2.kogpt2 import chatbot
from kobert.kobert import classify_emotion, classify_background, emotion_responses, emotion_category, background_category
from .models import DiaryEntry
import nltk
from django.contrib.auth import get_user_model
from rest_framework.permissions import AllowAny

nltk.download('punkt')

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
    
User = get_user_model()

class DiaryAnalysisView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        diary_text = request.data.get("diary_text", "")
        entry_date = request.data.get("entry_date", "")
        if not diary_text:
            return Response({"error": "No diary text provided"}, status=status.HTTP_400_BAD_REQUEST)
        if not entry_date:
            return Response({"error": "No entry date provided"}, status=status.HTTP_400_BAD_REQUEST)

        sentences = nltk.sent_tokenize(diary_text)
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

        emotion_distribution = {emotion: count / total_sentences for emotion, count in emotion_counts.items()}
        background_distribution = {background: count / total_sentences for background, count in background_counts.items()}

        most_felt_emotion = max(emotion_counts, key=emotion_counts.get)
        most_thought_background = max(background_counts, key=background_counts.get)
        response_message = emotion_responses.get(most_felt_emotion, "감정 분류 결과를 찾을 수 없습니다.")

        # 더미 유저 사용
        user = User.objects.get(username='dummy')

        DiaryEntry.objects.create(
            user=user,
            diary_text=diary_text,
            emotion_distribution=emotion_distribution,
            background_distribution=background_distribution,
            most_felt_emotion=most_felt_emotion,
            most_thought_background=most_thought_background,
            entry_date=entry_date
        )

        return Response({
            "emotion_distribution": emotion_distribution,
            "background_distribution": background_distribution,
            "most_felt_emotion": most_felt_emotion,
            "most_thought_background": most_thought_background,
            "response_message": response_message
        }, status=status.HTTP_200_OK)
    
# class DiaryAnalysisView(APIView):
#     def post(self, request, *args, **kwargs):
#         # 전체 일기를 받아옴
#         diary_text = request.data.get("diary_text", "")
#         entry_date = request.data.get("entry_date", "")
#         if not diary_text:
#             return Response({"error": "No diary text provided"}, status=status.HTTP_400_BAD_REQUEST)
#         if not entry_date:
#             return Response({"error": "No entry date provided"}, status=status.HTTP_400_BAD_REQUEST)

#         # 일기를 문장 단위로 나누기
#         sentences = nltk.sent_tokenize(diary_text)
#         if not sentences:
#             return Response({"error": "No sentences found in diary text"}, status=status.HTTP_400_BAD_REQUEST)

#         emotion_counts = {emotion: 0 for emotion in emotion_category.values()}
#         background_counts = {background: 0 for background in background_category.values()}
#         total_sentences = len(sentences)

#         for sentence in sentences:
#             emotion_probs, max_emotion = classify_emotion(sentence)
#             background_probs, max_background = classify_background(sentence)
#             emotion_counts[max_emotion] += 1
#             background_counts[max_background] += 1

#         # 감정, 배경 분포 계산
#         emotion_distribution = {emotion: count / total_sentences for emotion, count in emotion_counts.items()}
#         background_distribution = {background: count / total_sentences for background, count in background_counts.items()}

#         # 가장 많이 느낀 감정, 배경 찾기
#         most_felt_emotion = max(emotion_counts, key=emotion_counts.get)
#         most_thought_background = max(background_counts, key=background_counts.get)
#         response_message = emotion_responses.get(most_felt_emotion, "감정 분류 결과를 찾을 수 없습니다.")

#         # 데이터베이스에 저장
#         DiaryEntry.objects.create(
#             user=request.user,
#             diary_text=diary_text,
#             emotion_distribution=emotion_distribution,
#             background_distribution=background_distribution,
#             most_felt_emotion=most_felt_emotion,
#             most_thought_background=most_thought_background,
#             entry_date=entry_date  # 일기 작성 날짜 저장
#         )

#         return Response({
#             "emotion_distribution": emotion_distribution,
#             "background_distribution": background_distribution,
#             "most_felt_emotion": most_felt_emotion,
#             "most_thought_background": most_thought_background,
#             "response_message": response_message
#         }, status=status.HTTP_200_OK)