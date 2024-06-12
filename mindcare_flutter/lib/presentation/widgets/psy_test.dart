import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PsyTest {
  static Future<List<dynamic>> fetchTestResults(String surveyType) async {
    final token = await AuthHelpers.getToken();
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/psy_test/psy_test_get/$surveyType/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    // print(response.bodyBytes);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩하여 한글 깨짐 문제 해결
    } else {
      throw Exception('Failed to load test results');
    }
  }

  static Future<void> SubmitSurveyResult(int totalScore, String result, String surveyType) async {
    final url = Uri.parse('http://localhost:8000/api/psy_test/psy_test_results/');
    // const surveyType = 'anxiety'; // 예제에서는 'anxiety' 타입 사용

    final token = await AuthHelpers.getToken();
    if (token != null) {
      print('JWT Token: $token');
    } else {
      print('No JWT Token found.');
    }

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
}
