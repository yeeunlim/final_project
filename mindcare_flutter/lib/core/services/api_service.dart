import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import '../constants/urls.dart';
import 'auth_service.dart';
import 'dart:convert';

class ApiService {
  static Future<http.Response> sendAuthenticatedRequest(
      BuildContext context, String url, String method,
      {Map<String, String>? headers, dynamic body}) async {
    String? token = await AuthHelpers.getToken();
    if (token == null || JwtDecoder.isExpired(token)) {
      final refreshToken = await AuthHelpers.getRefreshToken();
      if (refreshToken == null || JwtDecoder.isExpired(refreshToken)) {
        _redirectToLogin(context);
        return Future.error('토큰이 만료되었습니다.');
      }

      // Refresh the token
      final newToken = await _refreshToken(context, refreshToken);
      if (newToken == null) {
        _redirectToLogin(context);
        return Future.error('토큰 갱신에 실패하였습니다.');
      }
      token = newToken;
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $token';
    headers['Content-Type'] = 'application/json';

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: headers);
        break;
      case 'POST':
        response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
        break;
      case 'PUT':
        response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
        break;
      case 'PATCH':
        response = await http.patch(Uri.parse(url), headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url), headers: headers);
        break;
      default:
        throw Exception('Invalid HTTP method');
    }

    if (response.statusCode == 401) {
      _redirectToLogin(context);
      return Future.error('토큰이 만료되었습니다.');
    }

    return response;
  }

  static Future<String?> _refreshToken(BuildContext context, String refreshToken) async {
    final response = await http.post(
      Uri.parse('$userAuthUrl/custom/refresh/'), // 리프레시 엔드포인트 URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['access'];
      await AuthHelpers.saveToken(newToken);
      return newToken;
    } else {
      return null;
    }
  }

  static void _redirectToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('토큰이 만료되었습니다. 다시 로그인해 주세요.')),
    );
  }
}
