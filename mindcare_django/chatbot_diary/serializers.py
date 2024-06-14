# serializers.py
from rest_framework import serializers
from .models import DiaryEntry

class DiaryEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = DiaryEntry
        fields = '__all__'

class MoodDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = DiaryEntry
        fields = ['entry_date', 'most_felt_emotion']

class MonthlyAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = DiaryEntry
        fields = [
            'entry_date', 'most_felt_emotion', 'most_thought_background', 'created_at', 'emotion_distribution'
        ]