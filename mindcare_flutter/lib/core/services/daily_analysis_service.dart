import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'dart:convert';
import 'api_service.dart';

class DailyAnalysisService {
  final BuildContext context;

  DailyAnalysisService(this.context);

  Future<String> fetchEmotionComment(String mostFeltEmotion) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/emotion_comment/',
      'POST',
      body: {'most_felt_emotion': mostFeltEmotion},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['emotion_comment'];
    } else {
      throw Exception('Failed to load response message');
    }
  }
}