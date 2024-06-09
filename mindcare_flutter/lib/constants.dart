import 'package:flutter/material.dart';

// API URLs
const String baseUrl = 'http://127.0.0.1:8000';

// Colors
const Color primaryColor = Colors.deepPurple;
const Color secondaryColor = Colors.white;
const Color backgroundColor = Colors.black;

// Emotion Colors
const Map<String, Color> emotionColors = {
  // 기쁜 마음
  '기쁨': Color(0xFFFFE0B2),      // 밝은 주황색
  '흥분': Color(0xFFFFD54F),     // 밝은 노란색
  '만족스러움': Color(0xFFFFC107), // 황금색
  '자신하는': Color(0xFFFFA000),  // 주황색
  '뿌듯함': Color(0xFFFF8F00),    // 진한 주황색
  '설렘': Color(0xFFFF6F00),      // 어두운 주황색

  // 평온한 마음
  '안도': Color(0xFFA5D6A7),      // 밝은 초록색
  '감사함': Color(0xFF81C784),    // 연한 초록색
  '여유로움': Color(0xFF66BB6A),  // 초록색
  '편안함': Color(0xFF4CAF50),    // 진한 초록색
  '무난함': Color(0xFF388E3C),    // 어두운 초록색

  // 놀란 마음
  '당황': Color(0xFFFFF59D),      // 밝은 노란색
  '부끄러움': Color(0xFFFFF176),  // 연한 노란색
  '놀람': Color(0xFFFFEB3B),      // 노란색
  '혼란스러움': Color(0xFFFDD835), // 진한 노란색

  // 불안한 마음
  '걱정': Color(0xFFE57373),      // 밝은 빨간색
  '불안': Color(0xFFEF5350),      // 연한 빨간색
  '두려움': Color(0xFFF44336),    // 빨간색

  // 불편한 마음
  '불편함': Color(0xFFFFAB91),    // 밝은 주황색
  '억울함': Color(0xFFFF8A65),    // 연한 주황색
  '부러움': Color(0xFFFF7043),    // 주황색
  '답답함': Color(0xFFFF5722),    // 진한 주황색
  '후회': Color(0xFFF4511E),      // 어두운 주황색
  '죄책감': Color(0xFFE64A19),    // 더 어두운 주황색

  // 힘든 마음
  '괴로움': Color(0xFFBDBDBD),    // 밝은 회색
  '지침': Color(0xFF9E9E9E),      // 연한 회색
  '무기력': Color(0xFF757575),    // 회색
  '허무함': Color(0xFF616161),    // 진한 회색
  '좌절감': Color(0xFF424242),    // 어두운 회색

  // 싫은 마음
  '자괴감': Color(0xFFD32F2F),    // 어두운 빨간색
  '짜증': Color(0xFFC62828),      // 더 어두운 빨간색
  '혐오': Color(0xFFB71C1C),      // 가장 어두운 빨간색
  '불쾌함': Color(0xFFD50000),    // 진한 빨간색
  '분노': Color(0xFFC51162),      // 진한 핑크색

  // 슬픈 마음
  '슬픔': Color(0xFF64B5F6),      // 밝은 파란색
  '우울함': Color(0xFF42A5F5),    // 연한 파란색
  '속상함': Color(0xFF2196F3),    // 파란색
  '실망': Color(0xFF1E88E5),      // 진한 파란색
  '외로움': Color(0xFF1976D2),    // 어두운 파란색
};

// Image URLs
class ImageUrls {
  static const String mainPageBackground = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/main_page.jpg';
  static const String loginPageBackground = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/log_in.jpg';
  static const String normalRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/normal_rabbit.png';
  static const String angryRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/anger_rabbit.png';
  static const String sadRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/sad_rabbit.png';
}