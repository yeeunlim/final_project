from django.db import models
from django.conf import settings

class DiaryEntry(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    diary_text = models.TextField()
    emotion_distribution = models.JSONField()
    background_distribution = models.JSONField()
    most_felt_emotion = models.CharField(max_length=50)
    most_thought_background = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    entry_date = models.DateField()