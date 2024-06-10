from django.contrib import admin
from django.urls import path, include
from users.views import CustomLoginView

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    # path('api/users/', include('users.urls', namespace='users')),
    # path('api/mypage/', include('mypage.urls', namespace='mypage')),
    path('api/chatbot_diary/', include('chatbot_diary.urls', namespace='chatbot_diary')),
    # path('api/analytics/', include('analytics.urls', namespace='analytics')),
    # path('api/htp/', include('htp.urls', namespace='htp')),
    # path('api/mbti/', include('mbti.urls', namespace='mbti')),
    # path('api/auth/', include('users.urls')),

    path('api/auth/', include('dj_rest_auth.urls')),
    path('api/auth/registration/', include('dj_rest_auth.registration.urls')),
    path('api/auth/custom/', include('users.urls')),  # Ensure this line is present
    path('api/auth/custom/login/', CustomLoginView.as_view(), name='custom-login'),  # CustomLoginView가 연결된 엔드포인트
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

]