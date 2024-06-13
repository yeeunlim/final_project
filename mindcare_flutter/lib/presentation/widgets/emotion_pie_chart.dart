import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class EmotionPieChart extends StatelessWidget {
  final Map<String, dynamic> emotionDistribution;

  const EmotionPieChart({super.key, required this.emotionDistribution});

  List<PieChartSectionData> getPieChartSections() {
    return emotionDistribution.entries.map((entry) {
      final color = emotionColors[entry.key];
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      );
    }).toList();
  }

  List<Widget> getEmotionLabels() {
    return emotionDistribution.entries.map((entry) {
      final color = emotionColors[entry.key] ?? Colors.grey;
      return Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            entry.key,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '감정의 분포',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: getPieChartSections(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getEmotionLabels(),
            ),
          ],
        ),
      ],
    );
  }
}
