import json
from django.db import models
from django.conf import settings
import os
from datetime import datetime

class DiaryEntry(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    diary_text = models.TextField()
    emotion_distribution = models.JSONField()
    background_distribution = models.JSONField()
    most_felt_emotion = models.CharField(max_length=50)
    most_thought_background = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    entry_date = models.DateField()
    emotion_sub_category = models.CharField(max_length=50, blank=True)
    emotion_major_category = models.CharField(max_length=50, blank=True)

    def save(self, *args, **kwargs):
        self.emotion_sub_category = self.get_emotion_sub_category(self.most_felt_emotion)
        self.emotion_major_category = self.get_emotion_major_category(self.most_felt_emotion)
        super().save(*args, **kwargs)

    def get_emotion_sub_category(self, emotion):
        chatbot_diary_dir = os.path.join(settings.BASE_DIR, 'chatbot_diary')
        json_file_path = os.path.join(chatbot_diary_dir, 'emotion_sub_category.json')
        with open(json_file_path, 'r', encoding='utf-8') as file:
            emotion_sub_category_map = json.load(file)
        return emotion_sub_category_map.get(emotion, '')
    
    def get_emotion_major_category(self, emotion):
        chatbot_diary_dir = os.path.join(settings.BASE_DIR, 'chatbot_diary')
        json_file_path = os.path.join(chatbot_diary_dir, 'emotion_major_category.json')
        with open(json_file_path, 'r', encoding='utf-8') as file:
            emotion_major_category_map = json.load(file)
        return emotion_major_category_map.get(emotion, '')

    def get_entry_weekday(self):
        weekday_number = self.entry_date.weekday()
        weekdays = ['월', '화', '수', '목', '금', '토', '일']
        return weekdays[weekday_number]