from rest_framework import serializers
from .models import PsyTestResult

class PsyTestResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = PsyTestResult
        fields = '__all__'
        read_only_fields = ['user']  # user 필드는 읽기 전용으로 설정