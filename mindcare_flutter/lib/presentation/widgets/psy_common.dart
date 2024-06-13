import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';
import 'package:mindcare_flutter/presentation/widgets/confirm_dialog.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test1.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test3.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PsyCommon {
  static final AuthHelpers _authHelpers = AuthHelpers();

  static Future<void> SubmitSurveyResult(int totalScore, String result, String surveyType) async {
    final url = Uri.parse('http://localhost:8000/api/psy_test/psy_test_results/');
    // const surveyType = 'anxiety'; // 예제에서는 'anxiety' 타입 사용

    final token = await AuthHelpers.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // JWT 토큰 추가
      },
      body: jsonEncode({'survey_type': surveyType, 'total_score': totalScore, 'result': result}),
    );

    if (response.statusCode == 201) {
      // 데이터가 성공적으로 저장됨
      print('Survey result saved successfully');
    } else {
      // 오류 발생
      print('Failed to save survey result');
      print('Response status: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> fetchTestResults(String surveyType) async {
    try {
      final token = await AuthHelpers.getToken();
      final url = Uri.parse('http://localhost:8000/api/psy_test/psy_test_get/$surveyType/');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩하여 한글 깨짐 문제 해결
      } else {
        throw Exception('Failed to load test results');
      }
    } catch (e) {
      print('Failed to load test results: $e');
      return [];
    }
  }

  static Future<void> deleteTestResult(String docId) async {
    print(docId);
    try {
      final token = await AuthHelpers.getToken();
      final url = Uri.parse('http://localhost:8000/api/psy_test/psy_test_delete/$docId/');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        // 삭제가 성공했을 때의 동작
        print('Test result deleted successfully');
      } else {
        throw Exception('Failed to delete test result');
      }
    } catch (e) {
      print('Failed to delete test result: $e');
    }
  }

  static String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static void showConfirmDialog(BuildContext context, String surveyType) {
    String testName = '';
    if (surveyType == 'anxiety'){
      testName = '불안 민감도 검사';  
    }else if (surveyType == 'stress'){
      testName = '스트레스 자각 검사';
    }else {
      testName = '노바코 분노 검사';
    }

    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기

              if( surveyType == 'anxiety'){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const psyServey1()), // 페이지로 이동
                );
              }else if( surveyType == 'stress') {
                Navigator.push(
                  context,                
                  MaterialPageRoute(builder: (context) => const psyServey2()), // 페이지로 이동
                );                
              }else {
                Navigator.push(
                  context,                
                  MaterialPageRoute(builder: (context) => const psyServey3()), // 페이지로 이동
                );                
              }


          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },

          message: '$testName검사를\n시작하시겠습니까?', // 메시지 전달
          confirmButtonText: '검사시작', // 확인 버튼 텍스트
          cancelButtonText: '취소', // 취소 버튼 텍스트
        );
      },
    );
  }  
}