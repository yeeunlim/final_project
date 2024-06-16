import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'api_service.dart';
import 'dart:convert';

class MonthlyAnalysisService {
  final BuildContext context;

  MonthlyAnalysisService(this.context);

  // 해당 유저의 모든 일기 엔트리에서 기분 데이터를 가져옴
  Future<Map<String, dynamic>> fetchMoodData() async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/mood_data/',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load mood data: ${response.statusCode}');
    }
  }

  // 특정 월의 일기 데이터 조회
  Future<List<dynamic>> fetchMonthlyData(DateTime selectedMonth) async {
    final year = selectedMonth.year;
    final month = selectedMonth.month;
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$chatbotDiaryUrl/monthly_analysis/$year/$month/',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load monthly data: ${response.statusCode}');
    }
  }
}
