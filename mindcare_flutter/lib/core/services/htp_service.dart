import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'api_service.dart';
import 'dart:convert';

class HTPApiService {
  final BuildContext context;

  HTPApiService(this.context);

  Future<Map<String, dynamic>?> uploadDrawingBase64(String base64Image, String type) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$htpTestUrl/upload_drawing/',
      'POST',
      body: {
        'image': base64Image,
        'type': type,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to upload drawing: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>?> finalizeDiagnosis(List<String> drawingIds) async {
    final response = await ApiService.sendAuthenticatedRequest(
      context,
      '$htpTestUrl/finalize_diagnosis/',
      'POST',
      body: {'drawingIds': drawingIds},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to finalize diagnosis: ${response.body}');
      return null;
    }
  }
}
