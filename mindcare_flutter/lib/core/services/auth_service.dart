import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';

class AuthHelpers {
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        print("No JWT token found");
        return null; // 예외를 던지지 않고 null 반환
      }
      print("JWT token found: $token");
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<bool> checkLoginStatus() async {
    try {
      final token = await getToken();
      print('Token retrieved: $token');
      if (token != null) {
        if (JwtDecoder.isExpired(token)) {
          print('Token expired');
          return false;
        }
        return true;
      }
    } catch (e) {
      print('Failed to check login status: $e');
    }
    return false;
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) {
        throw Exception("No refresh token found");
      }
      return refreshToken;
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<void> deleteRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$userAuthUrl/custom/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('jwt_token');
      await prefs.remove('refresh_token');
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

  static Future<bool> login(
      String username, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$userAuthUrl/custom/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);

        // 토큰이 저장되었는지 확인
        String? savedToken = prefs.getString('jwt_token');
        print('Saved JWT token: $savedToken');

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

  static Future<Map<String, dynamic>> fetchUserInfo() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    final response = await http.get(
      Uri.parse('$userAuthUrl/custom/info/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  static Future<void> deleteUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    final response = await http.delete(
      Uri.parse('$userAuthUrl/custom/delete/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<void> changePassword(
      String oldPassword, String newPassword) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    final response = await http.post(
      Uri.parse('$userAuthUrl/custom/change-password/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to change password');
    }
  }

  static Future<void> updateUserInfo(BuildContext context, String email, String name,
      String nickname, String birthdate, String? currentPassword, String? newPassword) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.put(
        Uri.parse('$userAuthUrl/custom/update/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'name': name,
          'nickname': nickname,
          'birthdate': birthdate,
          if (currentPassword != null) 'current_password': currentPassword,
          if (newPassword != null) 'new_password': newPassword,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
      } else {
        _handleError(responseData);
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception(e);
    }
  }

  static void _handleError(Map<String, dynamic> responseData) {
    if (responseData.containsKey('current_password')) {
      throw Exception(responseData['current_password'][0]);
    } else if (responseData.containsKey('email')) {
      throw Exception(responseData['email'][0]);
    } else if (responseData.containsKey('nickname')) {
      throw Exception(responseData['nickname'][0]);
    } else if (responseData.containsKey('non_field_errors')) {
      throw Exception(responseData['non_field_errors'][0]);
    } else {
      throw Exception('An unknown error occurred');
    }
  }
}
