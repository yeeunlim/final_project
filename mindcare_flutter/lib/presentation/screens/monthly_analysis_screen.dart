import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/api_service.dart';
import '../widgets/mood_tracker.dart';
import '../widgets/emotion_major_category_chart.dart';
import '../widgets/emotion_detailed_category_circles.dart';

class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({super.key});

  @override
  _MonthlyAnalysisScreenState createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  Future<List<dynamic>> fetchMoodData() async {
    return await MonthlyAnalysisService.fetchMoodData();
  }

  void _onDateSelected(DateTime selectedDate, bool hasDiary) async {
    if (hasDiary) {
      try {
        final responseData = await MonthlyAnalysisService.fetchDailyAnalysis(selectedDate);
        Navigator.pushNamed(
          context,
          '/daily_analysis',
          arguments: {
            'analysisData': responseData,
            'diaryText': responseData['diary_text'],
          },
        );
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
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
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '한눈에 보는 한 달의 감정 분석',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChartWidget(majorCategoryCounts: majorCategoryCounts),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: EmotionCircles(emotionCounts: emotionCounts),
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
}
