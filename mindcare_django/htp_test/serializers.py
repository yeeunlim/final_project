from rest_framework import serializers
from .models import Drawing

class DrawingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Drawing
        fields = ['id', 'user', 'type', 'image_url', 'result_image_url', 'result', 'created_at']
