from django.apps import AppConfig
import os
from .yolo import YOLOModel
from django.conf import settings

class HtpTestConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'htp_test'

    def ready(self):
        self.house_model = YOLOModel(os.path.join(settings.BASE_DIR, 'yolov5/House/best.pt'))
        self.tree_model = YOLOModel(os.path.join(settings.BASE_DIR, 'yolov5/Tree/best.pt'))
        self.person_model = YOLOModel(os.path.join(settings.BASE_DIR, 'yolov5/Person/best.pt'))
