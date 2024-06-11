import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, int> majorCategoryCounts;

  const BarChartWidget({Key? key, required this.majorCategoryCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('긍정');
                  case 1:
                    return const Text('중립');
                  case 2:
                    return const Text('부정');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: createStackedHorizontalBarGroups(majorCategoryCounts),
      ),
    );
  }

  List<BarChartGroupData> createStackedHorizontalBarGroups(Map<String, int> majorCategoryCounts) {
    final totalCount = majorCategoryCounts.values.reduce((a, b) => a + b);
    final positiveProportion = majorCategoryCounts['긍정']! / totalCount * 10;
    final neutralProportion = majorCategoryCounts['중립']! / totalCount * 10;
    final negativeProportion = majorCategoryCounts['부정']! / totalCount * 10;

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: positiveProportion,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: neutralProportion,
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: negativeProportion,
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      ),
    ];
  }
}
