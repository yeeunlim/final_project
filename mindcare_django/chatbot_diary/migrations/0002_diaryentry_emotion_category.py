# Generated by Django 5.0.6 on 2024-06-10 02:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('chatbot_diary', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='diaryentry',
            name='emotion_category',
            field=models.CharField(blank=True, max_length=50),
        ),
    ]