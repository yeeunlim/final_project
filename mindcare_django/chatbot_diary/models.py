import json
from django.db import models
from django.conf import settings
import os
from .helpers import analyze_text

class DiaryEntry(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    diary_text = models.TextField()
    emotion_distribution = models.JSONField()
    background_distribution = models.JSONField()
    most_felt_emotion = models.CharField(max_length=50)
    most_thought_background = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    entry_date = models.DateField()

    def save(self, *args, **kwargs):
        # 기존의 일기 텍스트를 가져와서 비교
        if self.pk is not None:
            old_entry = DiaryEntry.objects.get(pk=self.pk)
            if self.diary_text != old_entry.diary_text:
                analysis_result = analyze_text(self.diary_text)
                self.emotion_distribution = analysis_result["emotion_distribution"]
                self.background_distribution = analysis_result["background_distribution"]
                self.most_felt_emotion = analysis_result["most_felt_emotion"]
                self.most_thought_background = analysis_result["most_thought_background"]
            else:
                # 변경되지 않은 경우 기존 값을 유지
                self.emotion_distribution = old_entry.emotion_distribution
                self.background_distribution = old_entry.background_distribution
                self.most_felt_emotion = old_entry.most_felt_emotion
                self.most_thought_background = old_entry.most_thought_background
        else:
            # 새로운 엔트리인 경우 항상 분석 실행
            analysis_result = analyze_text(self.diary_text)
            self.emotion_distribution = analysis_result["emotion_distribution"]
            self.background_distribution = analysis_result["background_distribution"]
            self.most_felt_emotion = analysis_result["most_felt_emotion"]
            self.most_thought_background = analysis_result["most_thought_background"]

        super().save(*args, **kwargs)

    def get_entry_weekday(self):
        weekday_number = self.entry_date.weekday()
        weekdays = ['월', '화', '수', '목', '금', '토', '일']
        return weekdays[weekday_number]