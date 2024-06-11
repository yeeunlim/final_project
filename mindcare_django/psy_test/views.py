from django.shortcuts import render

# Create your views here.
from rest_framework import generics
from .models import PsyTestResult
from .serializers import PsyTestResultSerializer
from rest_framework.permissions import IsAuthenticated

class PsyTestResultCreateView(generics.CreateAPIView):
    queryset = PsyTestResult.objects.all()
    serializer_class = PsyTestResultSerializer
    permission_classes = [IsAuthenticated]  # 인증된 사용자만 접근 가능

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)  # 요청한 사용자를 저장