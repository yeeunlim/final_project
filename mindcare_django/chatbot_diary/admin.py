from django.contrib import admin
from .models import DiaryEntry

class DiaryEntryAdmin(admin.ModelAdmin):
    list_display = ('user', 'entry_date', 'most_felt_emotion', 'most_thought_background')
    search_fields = ('user__email', 'entry_date', 'most_felt_emotion', 'most_thought_background')

admin.site.register(DiaryEntry, DiaryEntryAdmin)