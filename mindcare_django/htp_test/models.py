from django.db import models
from django.conf import settings

class Drawing(models.Model):
    TYPE_CHOICES = [
        ('house', 'House'),
        ('tree', 'Tree'),
        ('person', 'Person'),
    ]
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    image_url = models.URLField()
    result_image_url = models.URLField(null=True, blank=True)
    result = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True, null=True)

    def __str__(self):
        return f'{self.type} drawing by {self.user.username}'
