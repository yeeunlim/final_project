import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class MonthlyAnalysisModel extends ChangeNotifier {
  Future<Map<String, dynamic>>? _moodDataFuture;
  Future<List<dynamic>>? _monthlyDataFuture;

  Future<Map<String, dynamic>>? get moodDataFuture => _moodDataFuture;
  Future<List<dynamic>>? get monthlyDataFuture => _monthlyDataFuture;

  void reloadData(DateTime selectedMonth) {
    _moodDataFuture = fetchMoodData();
    _monthlyDataFuture = fetchMonthlyData(selectedMonth);
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchMoodData() async {
    try {
      final moodData = await MonthlyAnalysisService.fetchMoodData();
      print('Fetched Mood Data: $moodData');
      return moodData;
    } catch (e) {
      print('Error in fetchMoodData: $e');
      return {};
    }
  }

  Future<List<dynamic>> fetchMonthlyData(DateTime selectedMonth) async {
    try {
      final monthlyData = await MonthlyAnalysisService.fetchMonthlyData(selectedMonth);
      print('Fetched Monthly Data: $monthlyData');
      return monthlyData;
    } catch (e) {
      print('Error in fetchMonthlyData: $e');
      return [];
    }
  }
}