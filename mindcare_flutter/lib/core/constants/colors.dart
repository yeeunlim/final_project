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
  '부정': Color(0xFF473EAE),
  '중립': Color(0xFF7676C2),

  '기쁜 마음': Color(0xFFD17C2A),
  '기쁨': Color(0xFFE2C2A4),
  '흥분': Color(0xFFD2B092),
  '만족스러움': Color(0xFFC2A589),
  '자신하는': Color(0xFFB39070),
  '뿌듯함': Color(0xFFA37C5D),
  '설렘': Color(0xFF94684A),

  '평온한 마음': Color(0xFF2D7930),
  '안도': Color(0xFF86A687),
  '감사함': Color(0xFF5CA785),
  '여유로움': Color(0xFF3D9274),
  '편안함': Color(0xFF208164),
  '무난함': Color(0xFF006854),

  '놀란 마음': Color(0xFFD3C458),
  '당황': Color(0xFFDFD3A4),
  '부끄러움': Color(0xFFD7C94A),
  '놀람': Color(0xFFD0C346),
  '혼란스러움': Color(0xFFC0A46A),

  '불안한 마음': Color(0xFF963C64),
  '걱정': Color(0xFFDAA1B8),
  '불안': Color(0xFFBB7B8D),
  '두려움': Color(0xFF963C64),

  '불편한 마음': Color(0xFF22276E),
  '불편함': Color(0xFF252F80),
  '억울함': Color(0xFF22276E),
  '부러움': Color(0xFF15165E),
  '답답함': Color(0xFF2D3A8F),
  '후회': Color(0xFF4C5699),
  '죄책감': Color(0xFF343D8D),

  '힘든 마음': Color(0xFF3D3D3D),
  '괴로움': Color(0xFF9E9E9E),
  '지침': Color(0xFF7F7F7F),
  '무기력': Color(0xFF606060),
  '허무함': Color(0xFF4E4E4E),
  '좌절감': Color(0xFF393939),

  '싫은 마음': Color(0xFF442065),
  '자괴감': Color(0xFF6D3385),
  '짜증': Color(0xFF5A2B6D),
  '혐오': Color(0xFF401E63),
  '불쾌함': Color(0xFF552F7A),
  '분노': Color(0xFF3D0F5B),

  '슬픈 마음': Color(0xFF1F6DB1),
  '슬픔': Color(0xFF90A8C9),
  '우울함': Color(0xFF698BAD),
  '속상함': Color(0xFF5279C2),
  '실망': Color(0xFF3A71B3),
  '외로움': Color(0xFF1E6CB4),
};


// 배경 색상 팔레트
const Map<String, Color> backgroundColors = {
  // 가족 (노란색 계열)
  '가족': Color(0xFFB59C1F),
  '자녀': Color(0xFF9B861B),
  '배우자': Color(0xFF7C6B16),
  '부모': Color(0xFF615614),

  // 관계 (핑크색 계열)
  '대인관계': Color(0xFFC3506D),
  '친구': Color(0xFFA6465E),
  '연애': Color(0xFF8C3C54),
  '결혼': Color(0xFF71314A),
  '임신,출산': Color(0xFF58263F),

  // 교육 (파란색 계열)
  '학교': Color(0xFF4A83AF),
  '학업': Color(0xFF3F6E9A),
  '진로': Color(0xFF355A81),
  '대학': Color(0xFF2B4A6E),
  '취업': Color(0xFF223A5A),

  // 사회 (보라색 계열)
  '직장': Color(0xFF7A4792),
  '사업': Color(0xFF663A7F),
  '경제적문제': Color(0xFF553069),
  '노후': Color(0xFF452657),

  // 건강 및 라이프스타일 (초록색 계열)
  '건강문제': Color(0xFF5AA462),
  '취미,운동': Color(0xFF4A9554),
  '다이어트': Color(0xFF3B7E44),
  '음주': Color(0xFF2F6A37),
  '성격': Color(0xFF25582D),
  '사고': Color(0xFF1B4523),
  '생활,거주': Color(0xFF12331A),
};
