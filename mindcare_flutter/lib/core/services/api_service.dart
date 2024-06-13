import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'auth_service.dart';

class ChatbotService {
  // 챗봇에 메시지를 보내는 메서드
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final token = await AuthHelpers.getToken();
    final response = await http.get(
      Uri.parse('$chatbotDiaryUrl/chatbot/?s=$message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 인증 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }
}

class DiaryEntryService {
  // 일기 엔트리 리스트 조회 (GET)
  Future<List<dynamic>> getDiaryEntries({String? entryDate}) async {
    final token = await AuthHelpers.getToken();
    final response = await http.get(
      Uri.parse(
          '$chatbotDiaryUrl/diary_entries${entryDate != null ? '?entry_date=$entryDate' : ''}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load diary entries');
    }
  }

  // 특정 ID의 일기 엔트리 조회 (GET)
  Future<Map<String, dynamic>> getDiaryEntryById(int diaryEntryId) async {
    final token = await AuthHelpers.getToken();
    final response = await http.get(
      Uri.parse('$chatbotDiaryUrl/diary_entries/$diaryEntryId/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load diary entry');
    }
  }

  // 일기 엔트리 생성 (POST)
  Future<Map<String, dynamic>> createDiaryEntry(
      String diaryText, String entryDate) async {
    final token = await AuthHelpers.getToken();
    final response = await http.post(
      Uri.parse('$chatbotDiaryUrl/diary_entries/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diary_text': diaryText,
        'entry_date': entryDate,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to create diary entry');
    }
  }

  // 일기 엔트리 수정 (PUT)
  Future<Map<String, dynamic>> updateDiaryEntry(
      int id, String diaryText, String entryDate) async {
    final token = await AuthHelpers.getToken();
    final response = await http.put(
      Uri.parse('$chatbotDiaryUrl/diary_entries/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diary_text': diaryText,
        'entry_date': entryDate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to update diary entry');
    }
  }

  // 일기 엔트리 부분 업데이트 (PATCH)
  Future<Map<String, dynamic>> patchDiaryEntry(
      int id, String diaryText, String entryDate) async {
    final token = await AuthHelpers.getToken();
    final response = await http.patch(
      Uri.parse('$chatbotDiaryUrl/diary_entries/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diary_text': diaryText,
        'entry_date': entryDate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to update diary entry');
    }
  }

  // 일기 엔트리 삭제 (DELETE)
  Future<void> deleteDiaryEntry(int id) async {
    final token = await AuthHelpers.getToken();
    final response = await http.delete(
      Uri.parse('$chatbotDiaryUrl/diary_entries/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete diary entry');
    }
  }
}

class DailyAnalysisService {
  Future<String> fetchEmotionComment(String mostFeltEmotion) async {
    final response = await http.post(
      Uri.parse('$chatbotDiaryUrl/emotion_comment/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'most_felt_emotion': mostFeltEmotion}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['emotion_comment'];
    } else {
      throw Exception('Failed to load response message');
    }
  }
}

class MonthlyAnalysisService {
  // 해당 유저의 모든 일기 엔트리에서 기분 데이터를 가져옴
  static Future<Map<String, dynamic>> fetchMoodData() async {
    final token = await AuthHelpers.getToken();
    try {
      final response = await http.get(
        Uri.parse('$chatbotDiaryUrl/mood_data/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 인증 토큰 추가
        },
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
  // 특정 월의 일기 데이터 조회
  static Future<List<dynamic>> fetchMonthlyData() async {
    final token = await AuthHelpers.getToken();
    try {
      final response = await http.get(
        Uri.parse('$chatbotDiaryUrl/monthly_analysis/2024/6/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 인증 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load monthly data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}



/// HTP TEST
class HTPApiService {
  static Future<Map<String, dynamic>?> uploadDrawingBase64(String base64Image, String type) async {
    String? token = await AuthHelpers.getToken(); // 토큰 가져오기
    if (token == null) {
      print('Token is missing!');
      return null;
    }

    final url = Uri.parse('$htpTestUrl/upload_drawing/');
    print("Uploading drawing with token: $token");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'image': base64Image,
        'type': type,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to upload drawing: ${response.body}');
      return null;
    }
  }

  static Future<List<dynamic>?> finalizeDiagnosis(List<String> drawingIds) async {
    String? token = await AuthHelpers.getToken(); // 토큰 가져오기
    if (token == null) {
      print('Token is missing!');
      return null;
    }

    final url = Uri.parse('$htpTestUrl/finalize_diagnosis/');
    print("Finalizing diagnosis with token: $token");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'drawingIds': drawingIds,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to finalize diagnosis: ${response.body}');
      return null;
    }
  }
}