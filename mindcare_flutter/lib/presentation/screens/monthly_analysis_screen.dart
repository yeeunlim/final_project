import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/emotion_pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:mindcare_flutter/core/services/monthly_analysis_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/services/diary_entry_service.dart';
import '../../core/utils/calculate_emotion_category_counts.dart';
import '../../core/utils/calculate_mood_score.dart';
import '../widgets/common_circle.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/mood_score_chart.dart';
import '../widgets/mood_tracker.dart';
import '../widgets/emotion_major_category_chart.dart';
import '../widgets/keyword_circles.dart';

class MonthlyAnalysisScreen extends StatefulWidget {
  const MonthlyAnalysisScreen({super.key});

  @override
  _MonthlyAnalysisScreenState createState() => _MonthlyAnalysisScreenState();
}

class _MonthlyAnalysisScreenState extends State<MonthlyAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadData();
    });
  }

  void _reloadData() {
    try {
      Provider.of<MonthlyAnalysisModel>(context, listen: false).reloadData();
    } catch (e) {
      print('Error reloading data: $e');
    }
  }

  void _onDateSelected(DateTime selectedDate, bool hasDiary) async {
    print(
        'Selected date in monthly analysis screen: $selectedDate, Has diary: $hasDiary');
    if (hasDiary) {
      try {
        final diaryEntryService = DiaryEntryService(context);
        final entries = await diaryEntryService.getDiaryEntries(
            entryDate: selectedDate.toIso8601String().split('T')[0]);
        if (entries.isNotEmpty) {
          final diaryEntry = entries.firstWhere((entry) =>
          entry['entry_date'] ==
              selectedDate.toIso8601String().split('T')[0]);
          final result = await Navigator.pushNamed(
            context,
            '/daily_analysis',
            arguments: {
              'entryDate': diaryEntry['entry_date'],
              'entryData': diaryEntry,
              'diaryText': diaryEntry['diary_text'],
            },
          );
          print('Navigation to /daily_analysis result: $result');
          if (result == true) {
            print('Reloading data for selected date: $selectedDate');
            _reloadData();
          }
        } else {
          throw Exception('No diary entry found');
        }
      } catch (e) {
        print('Error occurred while fetching diary entry: $e');
      }
    } else {
      print('Navigating to main screen');
      final result = await Navigator.pushNamed(
        context,
        '/chatbot_diary',
        arguments: {
          'selectedDate': selectedDate.toIso8601String().split('T')[0]
        },
      );
      print('Navigation to /chatbot_diary result: $result');
      if (result == true) {
        print('Reloading data for selected date: $selectedDate');
        _reloadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MonthlyAnalysisModel>(context);

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
                double analysisWidth = constraints.maxWidth < 800
                    ? constraints.maxWidth * 0.8
                    : 1000;
                double analysisHeight = constraints.maxHeight * 0.8;
                bool isVerticalLayout = constraints.maxWidth < 800;

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: isVerticalLayout
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildChildren(
                        context,
                        moodTrackerWidth,
                        moodTrackerHeight,
                        analysisWidth,
                        analysisHeight,
                        model),
                  )
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildChildren(
                          context,
                          moodTrackerWidth,
                          moodTrackerHeight,
                          analysisWidth,
                          analysisHeight,
                          model),
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

  List<Widget> buildChildren(
      BuildContext context,
      double moodTrackerWidth,
      double moodTrackerHeight,
      double analysisWidth,
      double analysisHeight,
      MonthlyAnalysisModel model) {
    return [
      Container(
        width: moodTrackerWidth,
        height: moodTrackerHeight,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: model.moodDataFuture == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, dynamic>>(
          future: model.moodDataFuture,
          builder: (context, snapshot) {
            print('Snapshot state: ${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Snapshot error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final moodData = snapshot.data ?? {};
              final moodMap = createMoodMap(moodData);

              return MoodTracker(
                moodData: moodMap,
                onDateSelected: _onDateSelected,
                onPageChanged: (focusedDay) {
                  print('mood tracker is calling provider: $focusedDay');
                  model.setFocusedMonth(focusedDay);
                },
                initialFocusedMonth: model.focusedMonth,
              );
            }
          },
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Container(
        width: analysisWidth,
        height: analysisHeight,
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          // 감정 분석 박스 내용 스크롤 가능하게 설정
          child: model.monthlyDataFuture == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<dynamic>>(
            future: model.monthlyDataFuture,
            builder: (context, monthlySnapshot) {
              if (monthlySnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (monthlySnapshot.hasError) {
                print('MonthlySnapshot error: ${monthlySnapshot.error}');
                return Center(
                    child: Text('Error: ${monthlySnapshot.error}'));
              } else if (!monthlySnapshot.hasData ||
                  monthlySnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30.0),
                      const Text(
                        '이번 달에는 아직 작성한 일기가 없어요.\n일기를 작성하고 월별 통계를 확인해보세요.',
                        style: TextStyle(fontSize: 20), // 텍스트 크기 조정
                        textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                      ),
                      const SizedBox(height: 16.0),
                      Image.network(
                        ImageUrls.analysisRabbit,
                        height: 100, // 이미지 높이 조정
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                );
              } else {
                final monthlyData = monthlySnapshot.data!;
                final majorCategoryCounts =
                calculateMajorCategoryCounts(monthlyData);
                final subCategoryRatios =
                calculateSubCategoryRatios(monthlyData);
                final dailyMoodScores =
                calculateDailyMoodScores(monthlyData);

                final totalEmotions =
                majorCategoryCounts.values.reduce((a, b) => a + b);

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '한눈에 보는 한 달의 감정 분석',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '한 달 간 느꼈던 감정은 몇 가지일까요?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonCircle(
                                circleText: totalEmotions.toString(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: BarChartWidget(
                                  majorCategoryCounts:
                                  majorCategoryCounts,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildDivider(), // 중복된 Divider 사용
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            '한 달 간 키워드를 확인해보세요!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          width: 600,
                          child: Center(
                            child: KeywordCircles(
                              monthlyData: monthlyData,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info, color: Colors.white),
                              SizedBox(width: 8.0),
                              Text(
                                '원이 흰색에 가까울수록 긍정적인 감정과, 보라색에 가까울수록 부정적인 감정과 자주 연결되었음을 나타내요.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    buildDivider(), // 중복된 Divider 사용
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            '이번 달의 기분 점수를 알아보세요.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CommonCircle(
                                circleText:
                                calculateAverageMoodScore(monthlyData)
                                    .toString(),
                              ),
                              const SizedBox(width: 40),
                              SizedBox(
                                height: 300,
                                width: 500,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: MoodScoreChart(
                                      dailyMoodScores: dailyMoodScores,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    buildDivider(), // 중복된 Divider 사용
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                            '한 달 동안 가졌던 마음을 요약해드릴게요!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16.0), // 내부 패딩
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.3), // 반투명한 흰색 배경
                            borderRadius: BorderRadius.circular(
                                100.0), // 모서리 둥글게 설정
                          ),
                          child: EmotionPieChart(
                            emotionDistribution: subCategoryRatios,
                          ),
                        ),
                      ],
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

  Widget buildDivider() {
    return const FractionallySizedBox(
      widthFactor: 1,
      child: Divider(
        color: lightGray,
        thickness: 3,
      ),
    );
  }
}

Map<DateTime, String> createMoodMap(Map<String, dynamic> moodData) {
  final moodMap = <DateTime, String>{};
  moodData.forEach((date, emotion) {
    final parsedDate = DateTime.parse(date);
    moodMap[parsedDate] = emotion;
  });
  return moodMap;
}
