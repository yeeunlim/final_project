import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
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
        AuthHelpers.redirectToLogin(context);
        return Future.error('토큰이 만료되었습니다.');
      }

      // Refresh the token
      final newToken = await AuthHelpers.refreshToken(context, refreshToken);
      if (newToken == null) {
        AuthHelpers.redirectToLogin(context);
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
      AuthHelpers.redirectToLogin(context);
      return Future.error('토큰이 만료되었습니다.');
    }

    return response;
  }
}
