from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('users.urls', namespace='users')),
    # path('api/mypage/', include('mypage.urls', namespace='mypage')),
    # path('api/diary/', include('chatbot_diary.urls', namespace='chatbot_diary')),
    # path('api/analytics/', include('analytics.urls', namespace='analytics')),
    # path('api/htp/', include('htp.urls', namespace='htp')),
    # path('api/mbti/', include('mbti.urls', namespace='mbti')),
]