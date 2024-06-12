import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';

class AuthHelpers {

  /// SharedPreferences 인스턴스를 통해 저장된 JWT 토큰을 반환하는 메서드
  /// 만약 토큰이 없다면 null을 반환
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        // 토큰이 없을 경우
        throw Exception("No JWT token found");
      }
      return token;
    } catch (e) {
      // 오류 처리
      print('Error getting token: $e');
      return null;
    }
  }
  
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
      // Uri.parse('http://localhost:8000/api/auth/custom/logout/'),
      Uri.parse('$userAuthUrl/custom/logout/'),
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
        // Uri.parse('http://localhost:8000/api/auth/custom/login/'),
        Uri.parse('$userAuthUrl/custom/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      // print('code::');
      // print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // print('data:============');
        // print(data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['access_token']); // 로그인 성공 시 액세스 토큰 저장
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

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

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('jwt_token');
        // print('token: ####');
        // print(token);

        if (token == null) {
          throw Exception('No JWT token found');
        }
        print(nickname + birthdate);

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
        print(response);
        print(response.statusCode);

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // 성공 처리 로직
          print('Success: ${response.body}');
        } else {
          // 오류 처리 로직
          print(response.body);
          // final Map<String, dynamic> responseData = jsonDecode(response.body);
            // 오류 처리 로직
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
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      print('Exception: $e');
      throw Exception(e);
    }
  }
}
