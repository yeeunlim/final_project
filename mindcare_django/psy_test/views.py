from django.shortcuts import render

# Create your views here.
from rest_framework import generics
from .models import PsyTestResult
from .serializers import PsyTestResultSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

# from rest_framework.decorators import api_view, permission_classes

class PsyTestResultCreateView(generics.CreateAPIView):
    queryset = PsyTestResult.objects.all()
    serializer_class = PsyTestResultSerializer
    permission_classes = [IsAuthenticated]  # 인증된 사용자만 접근 가능

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)  # 요청한 사용자를 저장

class PsyTestResultGetView(generics.ListAPIView):
    serializer_class = PsyTestResultSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        survey_type = self.kwargs['survey_type']
        return PsyTestResult.objects.filter(user=user, survey_type=survey_type).order_by('-created_at')
    
class PsyTestResultDeleteView(generics.DestroyAPIView):
    queryset = PsyTestResult.objects.all()
    serializer_class = PsyTestResultSerializer
    permission_classes = [IsAuthenticated]  # 인증된 사용자만 접근 가능
