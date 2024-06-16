import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'api_service.dart';
import 'dart:convert';

class ChatbotService {
  // 챗봇에 메시지를 보내는 메서드
  static Future<Map<String, dynamic>> sendMessage(BuildContext context, String message) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/chatbot/?s=$message',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }
}