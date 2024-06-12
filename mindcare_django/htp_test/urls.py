from django.urls import path
from .views import UploadDrawing, FinalizeDiagnosis

app_name = 'htp_test'

urlpatterns = [
    path('upload_drawing/', UploadDrawing.as_view(), name='upload_drawing'),
    path('finalize_diagnosis/', FinalizeDiagnosis.as_view(), name='finalize_diagnosis'),
]
