from django.urls import path
# from .views import UserProfileView
from .views import CustomRegisterView, CustomLoginView, LogoutView
app_name = 'users'

urlpatterns = [
    # path('profile/', UserProfileView.as_view(), name='user-profile'),

    # 최희정 추가
    path('registration/', CustomRegisterView.as_view(), name='custom_register'),
    # path('register/', CustomRegisterView.as_view(), name='custom_register'),
    # path('login/', CustomLoginView.as_view(), name='login'),
    path('login/', CustomLoginView.as_view(), name='custom-login'),
    path('logout/', LogoutView.as_view(), name='logout'),  # Add this line
]