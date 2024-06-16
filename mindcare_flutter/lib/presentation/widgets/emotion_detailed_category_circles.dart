import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mindcare_flutter/core/constants/emotion_categories.dart'; // 감정 카테고리 파일 임포트
import 'package:mindcare_flutter/core/constants/colors.dart'; // 색상 파일 임포트

class EmotionCircles extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionCircles({super.key, required this.emotionCounts});

  @override
  Widget build(BuildContext context) {
    final maxCount = emotionCounts.values.reduce(max); // 가장 빈번한 감정의 수를 찾습니다.
    final random = Random();

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
        const double minDistance = 10.0; // 최소 거리 설정
        final List<Map<String, dynamic>> circles = []; // 타입을 명시하여 리스트 선언

        // 원의 개수에 따라 boundingRect 크기 조정
        final int numberOfCircles = emotionCounts.length;
        final double baseWidth = containerSize.width * 0.4; // 기본 너비 설정
        final double baseHeight = containerSize.height * 0.4; // 기본 높이 설정
        final double boundingRectWidth = baseWidth + sqrt(numberOfCircles) * 70; // 원의 개수에 따라 너비 조정
        final double boundingRectHeight = baseHeight + sqrt(numberOfCircles) * 50; // 원의 개수에 따라 높이 조정
        final Rect boundingRect = Rect.fromLTWH(
          (containerSize.width - boundingRectWidth) / 2,
          (containerSize.height - boundingRectHeight) / 2,
          boundingRectWidth,
          boundingRectHeight,
        );

        for (var entry in emotionCounts.entries) {
          final proportion = entry.value / maxCount; // 비례 계산
          final radius = 20 + (proportion * 30); // 반지름 계산 (최대 반지름 50으로 설정)
          final emotion = entry.key;
          final majorCategory = emotionMajorCategory[emotion] ?? '중립'; // 대분류 구하기
          final color = emotionColors[majorCategory] ?? Colors.grey; // 색상 구하기

          bool isOverlapping;
          int tries = 0; // 시도 횟수 제한
          Offset offset;

          do {
            isOverlapping = false;

            // 포락선 안에서 랜덤 위치 생성
            final x = boundingRect.left + radius + (random.nextDouble() * (boundingRect.width - 2 * radius));
            final y = boundingRect.top + radius + (random.nextDouble() * (boundingRect.height - 2 * radius));
            offset = Offset(x, y);

            // 다른 원들과의 거리 계산
            for (var circle in circles) {
              final distanceBetweenCenters = (offset - circle['offset']).distance;
              if (distanceBetweenCenters < (circle['radius'] + radius + minDistance)) {
                isOverlapping = true;
                break;
              }
            }
            tries++;
          } while (isOverlapping && tries < 500); // 최대 500번 시도

          circles.add({
            'radius': radius,
            'emotion': emotion,
            'color': color,
            'offset': offset,
          });
        }

        return Center(
          child: SizedBox(
            width: containerSize.width,
            height: containerSize.height,
            child: Stack(
              children: circles.map((circle) {
                return Positioned(
                  left: (circle['offset'] as Offset).dx - (circle['radius'] as double),
                  top: (circle['offset'] as Offset).dy - (circle['radius'] as double),
                  child: Container(
                    width: 2 * (circle['radius'] as double), // 원의 지름을 설정
                    height: 2 * (circle['radius'] as double), // 원의 지름을 설정
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
            ),
          ),
        );
      },
    );
  }
}
