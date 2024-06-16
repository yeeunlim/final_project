import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/colors.dart';
import '../../core/utils/calculate_background_category_counts.dart';
import '../../core/utils/calculate_mood_score.dart';

class KeywordCircles extends StatelessWidget {
  final List<dynamic> monthlyData; // 월별 데이터를 추가

  const KeywordCircles({Key? key, required this.monthlyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Calculate keyword counts and mood scores using the provided monthly data
      final keywordCounts = calculateBackgroundCounts(monthlyData); // 변경된 함수 사용
      final keywordMoodScores = calculateKeywordMoodScores(monthlyData);

      final maxCount = keywordCounts.values.reduce((a, b) => a > b ? a : b); // 가장 빈번한 키워드의 수를 찾습니다.
      final random = Random();

      return LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
          final double minDistance = 10.0; // 최소 거리 설정
          final List<Map<String, dynamic>> circles = []; // 타입을 명시하여 리스트 선언

          // 원의 개수에 따라 boundingRect 크기 조정
          final int numberOfCircles = keywordCounts.length;
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

          // 기분 점수를 0.0 ~ 1.0 범위로 정규화하는 함수
          double normalizeScore(double score) {
            return (score + 100) / 200; // -100~100 범위를 0.0~1.0 범위로 변환
          }

          // 기분 점수에 따라 색상 설정 (0.0: 보라색, 1.0: 흰색)
          Color getBackgroundColor(double score) {
            double normalizedScore = normalizeScore(score);
            return Color.lerp(deepPurple, Colors.white, normalizedScore)!;
          }

          for (var entry in keywordCounts.entries) {
            final keyword = entry.key;
            final count = entry.value;
            final moodScore = keywordMoodScores[keyword] ?? 0.0;
            final color = getBackgroundColor(moodScore);

            final proportion = count / maxCount; // 비례 계산
            final radius = 20 + (proportion * 30); // 반지름 계산 (최대 반지름 50으로 설정)

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
              'keyword': keyword,
              'color': color,
              'offset': offset,
            });
          }

          return Center(
            child: Container(
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
                          circle['keyword'] as String,
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
    } catch (e) {
      debugPrint('Error: $e');
      return Center(child: Text('An error occurred: $e'));
    }
  }
}
