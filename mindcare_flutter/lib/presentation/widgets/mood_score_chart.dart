import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/constants/colors.dart';

class MoodScoreChart extends StatelessWidget {
  final Map<String, double> dailyMoodScores;

  MoodScoreChart({required this.dailyMoodScores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          size: Size(
            dailyMoodScores.length * 70.0, // 그래프의 너비를 일기 개수에 따라 동적으로 설정
            200, // 높이를 적절히 설정
          ),
          painter: MoodScoreChartPainter(
            dailyMoodScores: dailyMoodScores,
          ),
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

    final pixelInterval = 70; // 날짜 간격을 픽셀 단위로 고정

    final path = Path();
    bool isFirstPoint = true;

    // Draw Y-axis (Score)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    for (int i = -10; i <= 10; i += 5) {
      final y = ((10 - i) / 20) * size.height;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(color: Colors.black, fontSize: 12), // 텍스트 크기 조정
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-30, y - textPainter.height / 2)); // 왼쪽으로 떨어지게 설정

      // Draw horizontal lines
      if (i == 0) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), zeroLinePaint);
      }
    }

    // Draw X-axis (Dates)
    final dateFormatter = DateFormat('MM/dd');
    double x = 30;
    DateTime currentDate = minDate;

    while (x <= size.width) {
      textPainter.text = TextSpan(
        text: dateFormatter.format(currentDate),
        style: TextStyle(color: Colors.black, fontSize: 12), // 텍스트 크기 조정
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height));
      x += pixelInterval;
      currentDate = currentDate.add(Duration(days: 1));
    }

    canvas.translate(30, 0); // 전체 그래프를 오른쪽으로 이동

    // Draw a smooth curve instead of straight lines
    final smoothPath = Path();
    for (int i = 0; i < dates.length; i++) {
      final parsedDate = DateTime.parse(dates[i]);
      final daysOffset = parsedDate.difference(minDate).inDays;
      final x = daysOffset * pixelInterval / 1; // 날짜 간격을 픽셀 단위로 고정
      final y = ((10 - dailyMoodScores[dates[i]]!) / 20) * size.height;

      if (isFirstPoint) {
        smoothPath.moveTo(x, y);
        isFirstPoint = false;
      } else {
        final prevParsedDate = DateTime.parse(dates[i - 1]);
        final prevDaysOffset = prevParsedDate.difference(minDate).inDays;
        final prevX = prevDaysOffset * pixelInterval / 1;
        final prevY = ((10 - dailyMoodScores[dates[i - 1]]!) / 20) * size.height;
        final controlX = (prevX + x) / 2;
        smoothPath.cubicTo(controlX, prevY, controlX, y, x, y);
      }

      canvas.drawCircle(Offset(x, y), 6.0, pointPaint); // 점의 크기 조정
    }
    canvas.drawPath(smoothPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
