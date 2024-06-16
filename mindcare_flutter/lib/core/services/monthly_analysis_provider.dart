import 'package:flutter/material.dart';
import 'api_service.dart';

class MonthlyAnalysisModel extends ChangeNotifier {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Future<Map<String, dynamic>>? _moodDataFuture;
  Future<List<dynamic>>? _monthlyDataFuture;

  DateTime get focusedMonth => _focusedMonth;

  Future<Map<String, dynamic>>? get moodDataFuture => _moodDataFuture;

  Future<List<dynamic>>? get monthlyDataFuture => _monthlyDataFuture;

  void setFocusedMonth(DateTime focusedDay) {
    DateTime newFocusedMonth = DateTime(focusedDay.year, focusedDay.month);
    if (_focusedMonth != newFocusedMonth) {
      _focusedMonth = newFocusedMonth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          reloadData();
        }
      });
    }
  }

  void reloadData([DateTime? selectedMonth]) {
    final month = selectedMonth ?? _focusedMonth;
    print('Reloading data for month: $month');

    // 비동기 작업 전 Future 초기화
    _moodDataFuture = Future.value({});
    _monthlyDataFuture = Future.value([]);

    fetchMoodData().then((moodData) {
      _moodDataFuture = Future.value(moodData);
      notifyListeners();
      print('Mood data future updated and listeners notified');
    }).catchError((error) {
      print('Error fetching mood data: $error');
      _moodDataFuture = Future.value({});
      notifyListeners();
    });

    fetchMonthlyData(month).then((monthlyData) {
      _monthlyDataFuture = Future.value(monthlyData);
      notifyListeners();
      print('Monthly data future updated and listeners notified');
    }).catchError((error) {
      print('Error fetching monthly data: $error');
      _monthlyDataFuture = Future.value([]);
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> fetchMoodData() async {
    try {
      final moodData = await MonthlyAnalysisService.fetchMoodData();
      return moodData;
    } catch (e) {
      print('Error in fetchMoodData: $e');
      return {};
    }
  }

  Future<List<dynamic>> fetchMonthlyData(DateTime month) async {
    try {
      final monthlyData = await MonthlyAnalysisService.fetchMonthlyData(month);
      return monthlyData;
    } catch (e) {
      print('Error in fetchMonthlyData: $e');
      return [];
    }
  }
}