import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class BarChartPainter extends CustomPainter {
  final Map<String, int> majorCategoryCounts;

  BarChartPainter({required this.majorCategoryCounts});

  @override
  void paint(Canvas canvas, Size size) {
    final totalCount = majorCategoryCounts.values.fold(0, (sum, value) => sum + value);
    if (totalCount == 0) {
      return;
    }

    final positiveCount = majorCategoryCounts['긍정'] ?? 0;
    final neutralCount = majorCategoryCounts['중립'] ?? 0;
    final negativeCount = majorCategoryCounts['부정'] ?? 0;

    final positiveProportion = positiveCount / totalCount;
    final neutralProportion = neutralCount / totalCount;
    final negativeProportion = negativeCount / totalCount;

    final paintPositive = Paint()..color = emotionColors['긍정']!;
    final paintNeutral = Paint()..color = emotionColors['중립']!;
    final paintNegative = Paint()..color = emotionColors['부정']!;

    double startX = 0;

    // 긍정
    final positiveWidth = size.width * positiveProportion;
    canvas.drawRect(Rect.fromLTWH(startX, 0, positiveWidth, size.height), paintPositive);

    startX += positiveWidth;

    // 중립
    final neutralWidth = size.width * neutralProportion;
    canvas.drawRect(Rect.fromLTWH(startX, 0, neutralWidth, size.height), paintNeutral);

    startX += neutralWidth;

    // 부정
    final negativeWidth = size.width * negativeProportion;
    canvas.drawRect(Rect.fromLTWH(startX, 0, negativeWidth, size.height), paintNegative);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, int> majorCategoryCounts;

  const BarChartWidget({Key? key, required this.majorCategoryCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 480, // 고정 너비 설정
          height: 90, // 고정 높이 설정
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // 전체 모서리를 둥글게 설정
            child: CustomPaint(
              painter: BarChartPainter(majorCategoryCounts: majorCategoryCounts),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCountIndicator('긍정', majorCategoryCounts['긍정'] ?? 0, emotionColors['긍정']!),
            const SizedBox(width: 8),
            _buildCountIndicator('중립', majorCategoryCounts['중립'] ?? 0, emotionColors['중립']!),
            const SizedBox(width: 8),
            _buildCountIndicator('부정', majorCategoryCounts['부정'] ?? 0, emotionColors['부정']!),
          ],
        ),
      ],
    );
  }

  Widget _buildCountIndicator(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 25,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$count개',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}