# psyServey/urls.py
from django.urls import path
from .views import PsyTestResultCreateView, PsyTestResultGetView, PsyTestResultDeleteView

urlpatterns = [
    path('psy_test_results/', PsyTestResultCreateView.as_view(), name='psy_test_create'),
    path('psy_test_get/<str:survey_type>/', PsyTestResultGetView.as_view(), name='psy_test_get'),
    path('psy_test_delete/<int:pk>/', PsyTestResultDeleteView.as_view(), name='psy_test_delete'),
]