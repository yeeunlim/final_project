import 'package:flutter/material.dart';

// Colors
const Color primaryColor = Color(0xFF55446C);
const Color secondaryColor = Colors.white;
const Color backgroundColor = Colors.black;

// 감정 색상 팔레트
const Map<String, Color> emotionColors = {
  '기쁜 마음': Color(0xFFF8BF78),
  '기쁨': Color(0xFFFFE4C4),
  '흥분': Color(0xFFFFE0B2),
  '만족스러움': Color(0xFFFFDAB9),
  '자신하는': Color(0xFFFFCC80),
  '뿌듯함': Color(0xFFFFB74D),
  '설렘': Color(0xFFFFA726),

  '평온한 마음': Color(0xFF9BDC9E),
  '안도': Color(0xFFA5D6A7),
  '감사함': Color(0xFF73D0AC),
  '여유로움': Color(0xFF4DB69A),
  '편안함': Color(0xFF26A69A),
  '무난함': Color(0xFF00897B),

  '놀란 마음': Color(0xFFFCF18C),
  '당황': Color(0xFFFFF9C4),
  '부끄러움': Color(0xFFFFF176),
  '놀람': Color(0xFFFFEE58),
  '혼란스러움': Color(0xFFFFE082),

  '불안한 마음': Color(0xFFDC94AD),
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

  '힒든 마음': Color(0xFF757575),
  '괴로움': Color(0xFFBDBDBD),
  '지침': Color(0xFF9E9E9E),
  '무기력': Color(0xFF757575),
  '허무함': Color(0xFF616161),
  '좌절감': Color(0xFF424242),

  '싫은 마음': Color(0xFF501C8F),
  '자괴감': Color(0xFF863EA4),
  '짜증': Color(0xFF762FA1),
  '혐오': Color(0xFF501C8F),
  '불쾌함': Color(0xFF6A1B9A),
  '분노': Color(0xFF4A148C),

  '슬픈 마음': Color(0xFF85B4DA),
  '슬픔': Color(0xFFB0CFEA),
  '우울함': Color(0xFF85B4DA),
  '속상함': Color(0xFF66A8DC),
  '실망': Color(0xFF4695D5),
  '외로움': Color(0xFF2B81CB),
};