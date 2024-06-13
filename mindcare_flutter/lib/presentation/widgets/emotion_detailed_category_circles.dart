import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mindcare_flutter/core/constants/emotion_categories.dart'; // 감정 카테고리 파일 임포트
import 'package:mindcare_flutter/core/constants/colors.dart'; // 색상 파일 임포트

class EmotionCircles extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionCircles({Key? key, required this.emotionCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCount = emotionCounts.values.reduce(max); // 가장 빈번한 감정의 수를 찾습니다.
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: emotionCounts.entries.map((entry) {
        final proportion = entry.value / maxCount; // 비례 계산
        final radius = 50 + (proportion * 50); // 반지름 계산
        final emotion = entry.key;
        final majorCategory = emotionMajorCategory[emotion] ?? '중립'; // 대분류 구하기
        final color = emotionColors[majorCategory] ?? Colors.grey; // 색상 구하기

        return Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            color: color, // 색상 설정
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emotion,
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
