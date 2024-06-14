import 'package:flutter/material.dart';

// Colors
const Color primaryColor = Color(0xFF554569);
const Color secondaryColor = Colors.white;
const Color backgroundColor = Colors.black;
const Color lightGray = Color(0xFFC9C9C9);
const Color lightPurple = Color(0xFF8C8CEC);
const Color deepPurple = Color(0xFF564ECD);

// 감정 색상 팔레트
const Map<String, Color> emotionColors = {
  '긍정': Colors.white,
  '부정': Color(0xFF564ECD),
  '중립': Color(0xFF8C8CEC),

  '기쁜 마음': Color(0xFFEE9836),
  '기쁨': Color(0xFFFFE4C4),
  '흥분': Color(0xFFFFE0B2),
  '만족스러움': Color(0xFFFFDAB9),
  '자신하는': Color(0xFFFFCC80),
  '뿌듯함': Color(0xFFFFB74D),
  '설렘': Color(0xFFFFA726),

  '평온한 마음': Color(0xFF369438),
  '안도': Color(0xFFA5D6A7),
  '감사함': Color(0xFF73D0AC),
  '여유로움': Color(0xFF4DB69A),
  '편안함': Color(0xFF26A69A),
  '무난함': Color(0xFF00897B),

  '놀란 마음': Color(0xFFFCED6B),
  '당황': Color(0xFFFFF9C4),
  '부끄러움': Color(0xFFFFF176),
  '놀람': Color(0xFFFFEE58),
  '혼란스러움': Color(0xFFFFE082),

  '불안한 마음': Color(0xFFB9497F),
  '걱정': Color(0xFFF8BBD0),
  '불안': Color(0xFFDC94AD),
  '두려움': Color(0xFFB45C79),

  '불편한 마음': Color(0xFF283593),
  '불편함': Color(0xFF303F9F),
  '억울함': Color(0xFF283593),
  '부러움': Color(0xFF1A237E),
  '답답함': Color(0xFF3949AB),
  '후회': Color(0xFF5C6BC0),
  '죄책감': Color(0xFF3F51B5),

  '힘든 마음': Color(0xFF494949),
  '괴로움': Color(0xFFBDBDBD),
  '지침': Color(0xFF9E9E9E),
  '무기력': Color(0xFF757575),
  '허무함': Color(0xFF616161),
  '좌절감': Color(0xFF424242),

  '싫은 마음': Color(0xFF512488),
  '자괴감': Color(0xFF863EA4),
  '짜증': Color(0xFF762FA1),
  '혐오': Color(0xFF501C8F),
  '불쾌함': Color(0xFF6A1B9A),
  '분노': Color(0xFF4A148C),

  '슬픈 마음': Color(0xFF2686D5),
  '슬픔': Color(0xFFB0CFEA),
  '우울함': Color(0xFF85B4DA),
  '속상함': Color(0xFF66A8DC),
  '실망': Color(0xFF4695D5),
  '외로움': Color(0xFF2B81CB),
};

// 배경 색상 팔레트
const Map<String, Color> backgroundColors = {
  // 가족 (노란색 계열)
  '가족': Color(0xFFE1C62A),
  '자녀': Color(0xFFC2A526),
  '배우자': Color(0xFFA48420),
  '부모': Color(0xFF866A1B),

  // 관계 (핑크색 계열)
  '대인관계': Color(0xFFEA6387),
  '친구': Color(0xFFD45670),
  '연애': Color(0xFFBD4A63),
  '결혼': Color(0xFFA43D55),
  '임신,출산': Color(0xFF8B3248),

  // 교육 (파란색 계열)
  '학교': Color(0xFF5FA3D7),
  '학업': Color(0xFF528DC2),
  '진로': Color(0xFF4576A7),
  '대학': Color(0xFF396092),
  '취업': Color(0xFF2D4B7D),

  // 사회 (보라색 계열)
  '직장': Color(0xFF9558B2),
  '사업': Color(0xFF81479A),
  '경제적문제': Color(0xFF6E3A84),
  '노후': Color(0xFF5A2E6D),

  // 건강 및 라이프스타일 (초록색 계열)
  '건강문제': Color(0xFF6FBF73),
  '취미,운동': Color(0xFF5BAF61),
  '다이어트': Color(0xFF4A9E51),
  '음주': Color(0xFF3A8D41),
  '성격': Color(0xFF2C7D33),
  '사고': Color(0xFF1E6D25),
  '생활,거주': Color(0xFF105D17),
};