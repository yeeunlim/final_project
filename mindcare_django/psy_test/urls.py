# psyServey/urls.py
from django.urls import path
from .views import PsyTestResultCreateView

urlpatterns = [
    path('psy_test_results/', PsyTestResultCreateView.as_view(), name='psy_test_create'),
]