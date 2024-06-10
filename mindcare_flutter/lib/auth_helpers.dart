import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login.dart';

class AuthHelpers {
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print('jwt_token: $token');

    if (token != null) {
      try {
        final decodedToken = JwtDecoder.decode(token);
        print('Decoded Token: $decodedToken');
        print(JwtDecoder.isExpired(token));
        if (!JwtDecoder.isExpired(token)) {
          return true;
        }
      } catch (e) {
        print('Failed to decode token: $e');
        return false;
      }
    }
    return false;
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/auth/custom/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('jwt_token');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 실패')),
      );
    }
  }

  static Future<bool> login(String username, String password, BuildContext context) async {
    try {
      final response = await http.post(
        // Uri.parse('http://localhost:8000/api/auth/login/'),
        Uri.parse('http://localhost:8000/api/auth/custom/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('code::');
      print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('data:============');
        print(data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['access_token']); // 로그인 성공 시 액세스 토큰 저장
        print(prefs.getString('jwt_token'));

        return true;
      } else {
        print('로그인 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('로그인 중 예외 발생: $e');
      return false;
    }
  }
}
