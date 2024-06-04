from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('users.urls', namespace='users')),
    # path('api/mypage/', include('mypage.urls', namespace='mypage')),
    path('api/chatbot_diary/', include('chatbot_diary.urls', namespace='chatbot_diary')),
    # path('api/analytics/', include('analytics.urls', namespace='analytics')),
    # path('api/htp/', include('htp.urls', namespace='htp')),
    # path('api/mbti/', include('mbti.urls', namespace='mbti')),
    path('api/auth/', include('dj_rest_auth.urls')),
    path('api/auth/registration/', include('dj_rest_auth.registration.urls')),
]