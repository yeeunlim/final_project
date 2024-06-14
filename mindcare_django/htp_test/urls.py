from django.urls import path
from .views import UploadDrawing, FinalizeDiagnosis, HTPTestResultsView

app_name = 'htp_test'

urlpatterns = [
    path('upload_drawing/', UploadDrawing.as_view(), name='upload_drawing'),
    path('finalize_diagnosis/', FinalizeDiagnosis.as_view(), name='finalize_diagnosis'),
    path('results/', HTPTestResultsView.as_view(), name='htp_test_results'),
    path('results/<int:pk>/', HTPTestResultsView.as_view(), name='htp_test_result_delete'), 
]
