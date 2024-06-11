# Generated by Django 5.0.6 on 2024-06-10 05:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('chatbot_diary', '0002_diaryentry_emotion_category'),
    ]

    operations = [
        migrations.RenameField(
            model_name='diaryentry',
            old_name='emotion_category',
            new_name='emotion_sub_category',
        ),
        migrations.AddField(
            model_name='diaryentry',
            name='emotion_major_category',
            field=models.CharField(blank=True, max_length=50),
        ),
    ]