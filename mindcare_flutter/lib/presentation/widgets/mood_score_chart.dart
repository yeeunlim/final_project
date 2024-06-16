import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/constants/colors.dart';

class MoodScoreChart extends StatelessWidget {
  final Map<String, double> dailyMoodScores;

  const MoodScoreChart({super.key, required this.dailyMoodScores});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomPaint(
        size: Size(
          500, // 그래프의 너비를 고정
          260, // 높이를 적절히 설정
        ),
        painter: MoodScoreChartPainter(
          dailyMoodScores: dailyMoodScores,
        ),
      ),
    );
  }
}

class MoodScoreChartPainter extends CustomPainter {
  final Map<String, double> dailyMoodScores;

  MoodScoreChartPainter({required this.dailyMoodScores});

  @override
  void paint(Canvas canvas, Size size) {
    final double padding = 40.0; // 그래프 패딩 설정
    final double chartPadding = 20.0; // 그래프 좌우 패딩 설정
    final double chartWidth = size.width - padding * 2 - chartPadding * 2;
    final double chartHeight = size.height - padding * 2;

    final paint = Paint()
      ..color = deepPurple
      ..strokeWidth = 2.0 // 선의 두께를 적절하게 설정
      ..style = PaintingStyle.stroke;

    final zeroLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5 // 0점 선의 두께를 적절하게 설정
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = deepPurple
      ..style = PaintingStyle.fill;

    final dates = dailyMoodScores.keys.toList();
    dates.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    final maxDate = DateTime.parse(dates.last);
    final minDate = DateTime.parse(dates.first);
    final totalDays = maxDate.difference(minDate).inDays;

    final pixelInterval = chartWidth / (dates.length - 1); // 날짜 간격을 동적으로 설정

    final path = Path();
    bool isFirstPoint = true;

    // Draw Y-axis (Score)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    for (int i = -100; i <= 100; i += 50) {
      final y = padding + ((100 - i) / 200) * chartHeight;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 12), // 텍스트 크기 조정
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(padding - 30, y - textPainter.height / 2)); // 왼쪽으로 떨어지게 설정

      // Draw horizontal lines
      if (i == 0) {
        canvas.drawLine(Offset(padding + chartPadding, y), Offset(size.width - padding - chartPadding, y), zeroLinePaint);
      }
    }

    // Draw X-axis (Dates)
    final dateFormatter = DateFormat('MM/dd');
    double x = padding + chartPadding;
    DateTime currentDate = minDate;

    for (int i = 0; i < dates.length; i++) {
      if (i % 3 == 0) { // 3일 간격으로 날짜 표시
        textPainter.text = TextSpan(
          text: dateFormatter.format(DateTime.parse(dates[i])),
          style: const TextStyle(color: Colors.black, fontSize: 10), // 텍스트 크기 조정
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - padding + 10));
      }
      x += pixelInterval;
    }

    // Draw a smooth curve instead of straight lines
    final smoothPath = Path();
    for (int i = 0; i < dates.length; i++) {
      final parsedDate = DateTime.parse(dates[i]);
      final daysOffset = parsedDate.difference(minDate).inDays;
      final x = padding + chartPadding + daysOffset * pixelInterval; // 날짜 간격을 동적으로 설정
      final y = padding + ((100 - dailyMoodScores[dates[i]]!) / 200) * chartHeight;

      if (isFirstPoint) {
        smoothPath.moveTo(x, y);
        isFirstPoint = false;
      } else {
        final prevParsedDate = DateTime.parse(dates[i - 1]);
        final prevDaysOffset = prevParsedDate.difference(minDate).inDays;
        final prevX = padding + chartPadding + prevDaysOffset * pixelInterval;
        final prevY = padding + ((100 - dailyMoodScores[dates[i - 1]]!) / 200) * chartHeight;
        final controlX = (prevX + x) / 2;
        smoothPath.cubicTo(controlX, prevY, controlX, y, x, y);
      }

      canvas.drawCircle(Offset(x, y), 4.0, pointPaint); // 점의 크기 조정
    }
    canvas.drawPath(smoothPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
