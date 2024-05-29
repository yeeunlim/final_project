from django.urls import path
from .views import UserCreate, LoginView, LogoutView

app_name = 'users'

urlpatterns = [
    path('signup/', UserCreate.as_view(), name='signup'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
]