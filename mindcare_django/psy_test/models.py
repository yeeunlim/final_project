from django.db import models
from django.conf import settings

class PsyTestResult(models.Model):
    SURVEY_TYPES = (
        ('anxiety', '불안 민감도 질문지'),
        ('depression', '우울증 질문지'),
        ('stress', '스트레스 질문지'),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)  # 작성자 정보를 위한 필드 추가
    survey_type = models.CharField(max_length=50, choices=SURVEY_TYPES)
    total_score = models.IntegerField()
    result = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"User: {self.user.username}, Type: {self.get_survey_type_display()}, Score: {self.total_score}, Result: {self.result}"