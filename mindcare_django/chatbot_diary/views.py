from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from kogpt2.kogpt2 import chatbot
from kobert.kobert import classify_emotion, classify_background, emotion_responses, background_category
        
class ChatbotDiaryView(APIView):
    def get(self, request, *args, **kwargs):
        sentence = request.query_params.get("s", "")
        if not sentence:
            return Response({"error": "No input provided"}, status=status.HTTP_400_BAD_REQUEST)

        # 챗봇 응답 생성
        chatbot_response = chatbot(sentence)

        # 감정 및 배경 분류
        emotion_probs, max_emotion = classify_emotion(sentence)
        background_probs, max_background = classify_background(sentence)

        return Response({
            "chatbot_response": chatbot_response,
            "emotion_probs": emotion_probs,
            "max_emotion": max_emotion,
            "background_probs": background_probs,
            "max_background": max_background,
        }, status=status.HTTP_200_OK)

class DiaryAnalysisView(APIView):
    def post(self, request, *args, **kwargs):
        sentences = request.data.get("sentences", [])
        if not sentences:
            return Response({"error": "No sentences provided"}, status=status.HTTP_400_BAD_REQUEST)
        
        emotion_counts = {emotion: 0 for emotion in emotion_responses.keys()}  # Initialize emotion counts
        background_counts = {background: 0 for background in background_category.values()}  # Initialize background counts
        total_sentences = len(sentences)
        
        for sentence in sentences:
            _, max_emotion = classify_emotion(sentence)
            _, max_background = classify_background(sentence)
            emotion_counts[max_emotion] += 1
            background_counts[max_background] += 1
        
        # Calculate emotion and background distributions
        emotion_distribution = {emotion: count / total_sentences for emotion, count in emotion_counts.items()}
        background_distribution = {background: count / total_sentences for background, count in background_counts.items()}
        
        # Find the most frequently felt emotion and background
        most_felt_emotion = max(emotion_counts, key=emotion_counts.get)
        most_thought_background = max(background_counts, key=background_counts.get)
        response_message = emotion_responses.get(most_felt_emotion, "감정 분류 결과를 찾을 수 없습니다.")
        
        return Response({
            "emotion_distribution": emotion_distribution,
            "background_distribution": background_distribution,
            "most_felt_emotion": most_felt_emotion,
            "most_thought_background": most_thought_background,
            "response_message": response_message
        }, status=status.HTTP_200_OK)