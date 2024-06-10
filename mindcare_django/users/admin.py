from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import CustomUser

class CustomUserAdmin(BaseUserAdmin):
    list_display = ('email', 'username', 'name', 'nickname', 'birthdate')
    search_fields = ('email', 'username', 'name', 'nickname', 'birthdate')
    ordering = ('email',)

    # filter_horizontal 및 list_filter 속성 제거
    filter_horizontal = ()
    list_filter = ()


admin.site.register(CustomUser, CustomUserAdmin)
