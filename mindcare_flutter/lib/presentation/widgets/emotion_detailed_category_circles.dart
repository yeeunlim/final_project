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
    final random = Random();
    final size = MediaQuery.of(context).size;
    final List<Map<String, dynamic>> circles = []; // 타입을 명시하여 리스트 선언

    for (var entry in emotionCounts.entries) {
      final proportion = entry.value / maxCount; // 비례 계산
      final radius = 50 + (proportion * 50); // 반지름 계산
      final emotion = entry.key;
      final majorCategory = emotionMajorCategory[emotion] ?? '중립'; // 대분류 구하기
      final color = emotionColors[majorCategory] ?? Colors.grey; // 색상 구하기
      Offset offset;

      // 다른 원들과 겹치지 않도록 위치를 찾기
      bool isOverlapping;
      do {
        isOverlapping = false;
        offset = Offset(
          size.width / 2 + (random.nextDouble() - 0.5) * size.width / 2,
          size.height / 2 + (random.nextDouble() - 0.5) * size.height / 2,
        );

        for (var circle in circles) {
          final distance = (offset - circle['offset']).distance;
          if (distance < (circle['radius'] + radius) / 2) {
            isOverlapping = true;
            break;
          }
        }
      } while (isOverlapping);

      circles.add({
        'radius': radius,
        'emotion': emotion,
        'color': color,
        'offset': offset,
      });
    }

    return Stack(
      children: circles.map((circle) {
        return Positioned(
          left: (circle['offset'] as Offset).dx - (circle['radius'] as double) / 2,
          top: (circle['offset'] as Offset).dy - (circle['radius'] as double) / 2,
          child: Container(
            width: circle['radius'] as double,
            height: circle['radius'] as double,
            decoration: BoxDecoration(
              color: circle['color'] as Color, // 색상 설정
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                circle['emotion'] as String,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
