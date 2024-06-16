import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'api_service.dart';
import 'dart:convert';

class DiaryEntryService {
  final BuildContext context;

  DiaryEntryService(this.context);

  // 일기 엔트리 리스트 조회 (GET)
  Future<List<dynamic>> getDiaryEntries({String? entryDate}) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries${entryDate != null ? '?entry_date=$entryDate' : ''}',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load diary entries');
    }
  }

  // 특정 ID의 일기 엔트리 조회 (GET)
  Future<Map<String, dynamic>> getDiaryEntryById(int diaryEntryId) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries/$diaryEntryId/',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load diary entry');
    }
  }

  // 일기 엔트리 생성 (POST)
  Future<Map<String, dynamic>> createDiaryEntry(String diaryText, String entryDate) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries/',
      'POST',
      body: {
        'diary_text': diaryText,
        'entry_date': entryDate,
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to create diary entry');
    }
  }

  // 일기 엔트리 수정 (PUT)
  Future<Map<String, dynamic>> updateDiaryEntry(int id, String diaryText, String entryDate) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries/$id/',
      'PUT',
      body: {
        'diary_text': diaryText,
        'entry_date': entryDate,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to update diary entry');
    }
  }

  // 일기 엔트리 부분 업데이트 (PATCH)
  Future<Map<String, dynamic>> patchDiaryEntry(int id, String diaryText, String entryDate) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries/$id/',
      'PATCH',
      body: {
        'diary_text': diaryText,
        'entry_date': entryDate,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to update diary entry');
    }
  }

  // 일기 엔트리 삭제 (DELETE)
  Future<void> deleteDiaryEntry(int id) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/diary_entries/$id/',
      'DELETE',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete diary entry');
    }
  }
}
