import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, int> majorCategoryCounts;

  const BarChartWidget({Key? key, required this.majorCategoryCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Major Category Counts in Widget: $majorCategoryCounts');
    final totalCount = majorCategoryCounts.values.fold(0, (sum, value) => sum + value);
    if (totalCount == 0) {
      return Center(child: Text('No data available'));
    }

    final positiveProportion = majorCategoryCounts['긍정']! / totalCount * 10;
    final neutralProportion = majorCategoryCounts['중립']! / totalCount * 10;
    final negativeProportion = majorCategoryCounts['부정']! / totalCount * 10;

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
        barGroups: createStackedHorizontalBarGroups(positiveProportion, neutralProportion, negativeProportion),
      ),
    );
  }

  List<BarChartGroupData> createStackedHorizontalBarGroups(double positiveProportion, double neutralProportion, double negativeProportion) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: positiveProportion.isNaN ? 0 : positiveProportion,
            color: emotionColors['긍정'], // 색상 변경
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: neutralProportion.isNaN ? 0 : neutralProportion,
            color: emotionColors['중립'], // 색상 변경
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: negativeProportion.isNaN ? 0 : negativeProportion,
            color: emotionColors['부정'], // 색상 변경
            width: 20,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      ),
    ];
  }
}
