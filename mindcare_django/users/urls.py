from django.urls import path
from .views import UserProfileView

app_name = 'users'

urlpatterns = [
    path('profile/', UserProfileView.as_view(), name='user-profile'),
]