# Generated by Django 5.0.6 on 2024-06-13 08:20

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('chatbot_diary', '0003_rename_emotion_category_diaryentry_emotion_sub_category_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='diaryentry',
            name='emotion_major_category',
        ),
        migrations.RemoveField(
            model_name='diaryentry',
            name='emotion_sub_category',
        ),
    ]