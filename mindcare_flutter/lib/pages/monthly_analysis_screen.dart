import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../widgets/mood_tracker.dart';
import 'dart:math';

class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({Key? key}) : super(key: key);

  @override
  _MonthlyAnalysisScreenState createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  Future<List<dynamic>> fetchMoodData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chatbot_diary/monthly_data/2024/6/'), // API 엔드포인트
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load mood data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  void _onDateSelected(DateTime selectedDate, bool hasDiary) async {
    if (hasDiary) {
      // 일기가 있는 날짜일 경우
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/chatbot_diary/daily_analysis/$selectedDate'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(utf8.decode(response.bodyBytes));
          Navigator.pushNamed(
            context,
            '/daily_analysis',
            arguments: {
              'analysisData': responseData,
              'diaryText': responseData['diary_text'], // 일기 텍스트를 전달
            },
          );
        } else {
          print('Failed to load diary: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      // 일기가 없는 날짜일 경우
      Navigator.pushNamed(context, '/diary_entry', arguments: {'entryDate': selectedDate});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analysis'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchMoodData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No mood data available'));
          } else {
            final moodData = snapshot.data!;
            final majorCategoryCounts = calculateMajorCategoryCounts(moodData);
            final emotionCounts = calculateEmotionCounts(moodData);
            final moodMap = createMoodMap(moodData);
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoodTracker(
                      moodData: moodMap,
                      onDateSelected: _onDateSelected,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '한눈에 보는 한 달의 감정 분석',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChart(
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
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: createStackedHorizontalBarGroups(majorCategoryCounts),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: createEmotionCircles(emotionCounts),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Map<String, int> calculateMajorCategoryCounts(List<dynamic> moodData) {
    final counts = {'긍정': 0, '중립': 0, '부정': 0};
    for (var entry in moodData) {
      final category = entry['emotion_major_category'];
      if (counts.containsKey(category)) {
        counts[category] = counts[category]! + 1;
      }
    }
    return counts;
  }

  Map<String, int> calculateEmotionCounts(List<dynamic> moodData) {
    final counts = <String, int>{};
    for (var entry in moodData) {
      final emotion = entry['most_felt_emotion'];
      if (counts.containsKey(emotion)) {
        counts[emotion] = counts[emotion]! + 1;
      } else {
        counts[emotion] = 1;
      }
    }
    return counts;
  }

  Map<DateTime, String> createMoodMap(List<dynamic> moodData) {
    final moodMap = <DateTime, String>{};
    for (var entry in moodData) {
      final date = DateTime.parse(entry['entry_date']);
      final emotion = entry['most_felt_emotion'];
      moodMap[date] = emotion;
    }
    return moodMap;
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

  List<Widget> createEmotionCircles(Map<String, int> emotionCounts) {
    final maxCount = emotionCounts.values.reduce(max);
    return emotionCounts.entries.map((entry) {
      final proportion = entry.value / maxCount;
      final radius = 50 + (proportion * 50);
      return Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            entry.key,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }
}
