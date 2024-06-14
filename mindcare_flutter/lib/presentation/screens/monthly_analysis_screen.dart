import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/api_service.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/constants/emotion_categories.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/mood_tracker.dart';
import '../widgets/emotion_major_category_chart.dart';
import '../widgets/emotion_detailed_category_circles.dart';

class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({super.key});

  @override
  _MonthlyAnalysisScreenState createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  Future<Map<String, dynamic>> fetchMoodData() async {
    try {
      final moodData = await MonthlyAnalysisService.fetchMoodData();
      print('Fetched Mood Data: $moodData'); // 데이터를 출력하여 확인
      return moodData;
    } catch (e) {
      print('Error in fetchMoodData: $e');
      return {};
    }
  }

  Future<List<dynamic>> fetchMonthlyData() async {
    try {
      final monthlyData = await MonthlyAnalysisService.fetchMonthlyData();
      print('Fetched Monthly Data: $monthlyData'); // 데이터를 출력하여 확인
      return monthlyData;
    } catch (e) {
      print('Error in fetchMonthlyData: $e');
      return [];
    }
  }

  void _onDateSelected(DateTime selectedDate, bool hasDiary) async {
    print('Selected date: $selectedDate');
    print('Has diary: $hasDiary');
    if (hasDiary) {
      try {
        final diaryEntryService = DiaryEntryService();
        final entries = await diaryEntryService.getDiaryEntries(
            entryDate: selectedDate.toIso8601String().split('T')[0]);
        if (entries.isNotEmpty) {
          final diaryEntry = entries.firstWhere((entry) =>
          entry['entry_date'] ==
              selectedDate.toIso8601String().split('T')[0]);
          print('Fetched diary entry: $diaryEntry');
          Navigator.pushNamed(
            context,
            '/daily_analysis',
            arguments: {
              'entryDate': diaryEntry['entry_date'],
              'entryData': diaryEntry,
              'diaryText': diaryEntry['diary_text'],
            },
          );
        } else {
          throw Exception('No diary entry found');
        }
      } catch (e) {
        print('Error occurred while fetching diary entry: $e');
      }
    } else {
      print('Navigating to main screen');
      Navigator.pushNamed(
        context,
        '/chatbot_diary',
        arguments: {
          'selectedDate': selectedDate.toIso8601String().split('T')[0]
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // 공통 AppBar 사용
      drawer: const CustomDrawer(), // 공통 Drawer 사용
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ImageUrls.mainPageBackground),
                // AWS S3에서 이미지 로드
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double moodTrackerWidth = 400;
                double moodTrackerHeight = 470;
                double analysisWidth = constraints.maxWidth < 800 ? constraints.maxWidth * 0.8 : 1000;
                double analysisHeight = constraints.maxHeight * 0.8;
                bool isVerticalLayout = constraints.maxWidth < 800;

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: isVerticalLayout
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildChildren(context, moodTrackerWidth, moodTrackerHeight, analysisWidth, analysisHeight),
                  )
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildChildren(context, moodTrackerWidth, moodTrackerHeight, analysisWidth, analysisHeight),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildChildren(BuildContext context, double moodTrackerWidth, double moodTrackerHeight, double analysisWidth, double analysisHeight) {
    return [
      Container(
        width: moodTrackerWidth,
        height: moodTrackerHeight,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchMoodData(),
          builder: (context, snapshot) {
            print('Snapshot state: ${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Snapshot error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print('No data in snapshot');
              return const Center(child: Text('No mood data available'));
            } else {
              final moodData = snapshot.data!;
              print('Mood data in builder: $moodData');
              final moodMap = createMoodMap(moodData);
              print('Mood map: $moodMap');

              return MoodTracker(
                moodData: moodMap,
                onDateSelected: _onDateSelected,
              );
            }
          },
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Container(
        width: analysisWidth,
        height: analysisHeight,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView( // 감정 분석 박스 내용 스크롤 가능하게 설정
          child: FutureBuilder<List<dynamic>>(
            future: fetchMonthlyData(),
            builder: (context, monthlySnapshot) {
              if (monthlySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (monthlySnapshot.hasError) {
                return Center(child: Text('Error: ${monthlySnapshot.error}'));
              } else if (!monthlySnapshot.hasData || monthlySnapshot.data!.isEmpty) {
                return const Center(child: Text('No monthly data available'));
              } else {
                final monthlyData = monthlySnapshot.data!;
                print('Monthly data in builder: $monthlyData');
                final majorCategoryCounts = calculateMajorCategoryCounts(monthlyData);
                final emotionCounts = calculateEmotionCounts(monthlyData);
                print('Major Category Counts in Widget: $majorCategoryCounts');

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '한눈에 보는 한 달의 감정 분석',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300, // 고정 높이 설정
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChartWidget(majorCategoryCounts: majorCategoryCounts),
                      ),
                    ),
                    SizedBox(
                      height: 300, // 고정 높이 설정
                      child: Center(
                        child: EmotionCircles(emotionCounts: emotionCounts),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    ];
  }

  // majorCategoryCounts와 계산
  Map<String, int> calculateMajorCategoryCounts(List<dynamic> monthlyData) {
    final counts = {'긍정': 0, '중립': 0, '부정': 0};
    for (var entry in monthlyData) {
      final emotion = entry['most_felt_emotion'];
      final majorCategory = emotionMajorCategory[emotion] ?? '중립';
      if (counts.containsKey(majorCategory)) {
        counts[majorCategory] = counts[majorCategory]! + 1;
      }
    }
    print('Major Category Counts: $counts'); // 데이터를 출력하여 확인
    return counts;
  }

  // 감정별 횟수 계산
  Map<String, int> calculateEmotionCounts(List<dynamic> monthlyData) {
    final counts = <String, int>{};
    for (var entry in monthlyData) {
      final emotion = entry['most_felt_emotion'];
      if (counts.containsKey(emotion)) {
        counts[emotion] = counts[emotion]! + 1;
      } else {
        counts[emotion] = 1;
      }
    }
    return counts;
  }

  Map<DateTime, String> createMoodMap(Map<String, dynamic> moodData) {
    final moodMap = <DateTime, String>{};
    moodData.forEach((date, emotion) {
      final parsedDate = DateTime.parse(date);
      moodMap[parsedDate] = emotion;
    });
    return moodMap;
  }
}
