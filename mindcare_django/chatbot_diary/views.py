from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from kogpt2.kogpt2 import chatbot
from .models import DiaryEntry
from .serializers import DiaryEntrySerializer, MoodDataSerializer, MonthlyAnalysisSerializer
from django.contrib.auth import get_user_model
from rest_framework.permissions import AllowAny, IsAuthenticated

User = get_user_model()

class ChatbotResponseView(APIView):
    """
    챗봇 응답을 생성하는 뷰
    """
    def get(self, request, *args, **kwargs):
        sentence = request.query_params.get("s", "")
        if not sentence:
            return Response({"error": "No input provided"}, status=status.HTTP_400_BAD_REQUEST)

        # 챗봇 응답 생성
        chatbot_response = chatbot(sentence)

        return Response({
            "chatbot_response": chatbot_response,
        }, status=status.HTTP_200_OK)

class DiaryEntryViewSet(viewsets.ModelViewSet):
    """
    일기 엔트리의 CRUD 작업을 처리하는 ViewSet
    """
    queryset = DiaryEntry.objects.all()
    serializer_class = DiaryEntrySerializer
    permission_classes = [IsAuthenticated]  # 로그인한 유저만 접근 가능

    def get_queryset(self):
        """
        user와 entryDate로 일기 조회
        """
        user = self.request.user
        if not user.is_authenticated or user.username == 'dummy':
            user = User.objects.get(username='dummy')
        return DiaryEntry.objects.filter(user=user)

    def retrieve(self, request, *args, **kwargs):
        """
        해당 id를 가진 일기 한 개를 반환
        """
        diary = self.get_object()
        serializer = self.get_serializer(diary)
        return Response(serializer.data)
    
    def create(self, request, *args, **kwargs):
        """
        일기 엔트리를 생성
        """
        user = request.user
        diary_text = request.data.get("diary_text", "")
        entry_date = request.data.get("entry_date", "")

        if not diary_text or not entry_date:
            return Response({"error": "Diary text and entry date are required"}, status=status.HTTP_400_BAD_REQUEST)

        diary_entry = DiaryEntry(user=user, diary_text=diary_text, entry_date=entry_date)
        diary_entry.save()

        serializer = DiaryEntrySerializer(diary_entry)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """
        일기 엔트리를 수정
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        instance.diary_text = request.data.get("diary_text", instance.diary_text)
        instance.entry_date = request.data.get("entry_date", instance.entry_date)
        instance.save()

        serializer = DiaryEntrySerializer(instance)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def destroy(self, request, *args, **kwargs):
        """
        일기 엔트리를 삭제
        """
        instance = self.get_object()
        instance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class MoodDataViewSet(viewsets.ViewSet):
    """
    사용자의 기분 데이터를 조회하는 ViewSet
    """
    permission_classes = [AllowAny]

    def list(self, request):
        """
        사용자의 모든 일기 엔트리를 조회하고 기분 데이터를 반환
        """
        user = request.user
        if not user.is_authenticated or user.username == 'dummy':
            user = User.objects.get(username='dummy')
        
        entries = DiaryEntry.objects.filter(user=user)
        serializer = MoodDataSerializer(entries, many=True)
        
        # 데이터를 JSON 형식으로 변환
        mood_data = {entry['entry_date']: entry['most_felt_emotion'] for entry in serializer.data}
        return Response(mood_data, status=status.HTTP_200_OK)

class MonthlyAnalysisViewSet(viewsets.ViewSet):
    """
    특정 연도와 월의 일기 데이터를 조회하는 ViewSet
    """
    permission_classes = [AllowAny]

    def list(self, request, year, month):
        """
        특정 연도와 월의 사용자의 일기 엔트리를 조회하고 분석 데이터를 반환
        """
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