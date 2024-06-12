import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScoreChart(myScore: 11),
    );
  }
}

class ScoreChart extends StatelessWidget {
  final int myScore;
  const ScoreChart({super.key, required this.myScore});

  static BarChartGroupData makeGroupData(int x, int y, Color barColor) {
    return BarChartGroupData(
      barsSpace: 0,
      x: x,
      barRods: [
        BarChartRodData(
          toY: 1,
          width: (y - x).toDouble()*6.2, // 막대의 너비 조절
          color: barColor,
          borderRadius: BorderRadius.zero,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [
      makeGroupData(0, 15, Colors.blue),
      makeGroupData(15, 20, Colors.green),
      makeGroupData(20, 24, Colors.orange),
      makeGroupData(24, 64, Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Chart'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 150,
          child: Stack(
            children: [
              const Positioned(
                top: 10,
                left: 10,
                child: Text(
                  'My Score: 11',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 세로축 숫자 숨기기
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            );
                            switch (value.toInt()) {
                              case 0:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const Text('0~15', style: style),
                                );
                              case 15:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const Text('16~20', style: style),
                                );
                              case 20:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const Text('21~24', style: style),
                                );
                              case 24:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const Text('25~64', style: style),
                                );
                              default:
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: const Text('', style: style),
                                );
                            }
                          },
                          reservedSize: 38,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                    barGroups: barGroups,
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
