import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mindcare_flutter/core/constants/app_constants.dart';

class ApiService {
  // 챗봇에 메시지를 보내는 메서드
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await http.get(
      Uri.parse('$chatbotDiaryUrl/chatbot/?s=$message'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }

  // 일기를 저장하는 메서드
  static Future<Map<String, dynamic>> saveDiary(String diaryText, String entryDate) async {
    final response = await http.post(
      Uri.parse('$chatbotDiaryUrl/diary_analysis/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'diary_text': diaryText,
        'entry_date': entryDate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to save diary: ${response.statusCode}');
    }
  }
}

class DailyAnalysisService {
  static Future<void> deleteDiaryEntry(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$chatbotDiaryUrl/diary_entries/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete diary entry: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<void> updateDiaryEntry(int id, String diaryText, String entryDate) async {
    try {
      final Map<String, dynamic> requestData = {
        'diary_text': diaryText,
        'entry_date': entryDate,
      };

      final response = await http.patch(
        Uri.parse('$chatbotDiaryUrl/diary_entries/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update diary entry: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}

class MonthlyAnalysisService {
  static Future<List<dynamic>> fetchMoodData() async {
    try {
      final response = await http.get(
        Uri.parse('$chatbotDiaryUrl/monthly_analysis/2024/6/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load mood data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchDailyAnalysis(DateTime selectedDate) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chatbot_diary/daily_analysis/$selectedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load diary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}