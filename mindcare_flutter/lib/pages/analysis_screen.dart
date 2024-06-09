import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../constants.dart';

class AnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData; // 분석 데이터를 저장하는 변수
  final String diaryText; // 일기 텍스트를 저장하는 변수

  const AnalysisScreen(
      {Key? key, required this.analysisData, required this.diaryText})
      : super(key: key);

  // 감정 분포를 PieChartSectionData 리스트로 변환하는 함수
  List<PieChartSectionData> getPieChartSections(
      Map<String, dynamic> emotionDistribution) {
    return emotionDistribution.entries.map((entry) {
      final color = emotionColors[entry.key] ?? Colors.grey; // 컬러 팔레트에서 색상 가져오기, 없으면 회색
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value.toStringAsFixed(1)}%',
        // % 비율 추가
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      );
    }).toList();
  }

  // 감정 분포 색상과 이름을 표시하는 위젯 리스트 생성 함수
  List<Widget> getEmotionLabels(Map<String, dynamic> emotionDistribution) {
    return emotionDistribution.entries.map((entry) {
      final color = emotionColors[entry.key] ?? Colors.grey; // 컬러 팔레트에서 색상 가져오기, 없으면 회색
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
    return Scaffold(
      appBar: const CustomAppBar(), // 공통 AppBar 사용
      drawer: const CustomDrawer(), // 공통 Drawer 사용
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ImageUrls.mainPageBackground), // AWS S3에서 이미지 로드
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                // 분석 리포트 박스의 배경을 반투명 흰색으로 설정
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                    children: [
                      Image.network(
                        ImageUrls.normalRabbit, // AWS S3에서 이미지 로드
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '오늘의 일기 분석',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2, // 일기 부분의 넓이 비율을 2로 설정
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white, // 일기 부분의 배경을 반투명 흰색으로 설정
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                diaryText,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16), // 텍스트 크기를 16으로 설정
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3, // 분석 결과 부분의 넓이 비율을 3로 설정
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              // 분석 결과 부분의 배경을 반투명 흰색으로 설정
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // 중앙 정렬
                                children: [
                                  const Text(
                                    '감정의 분포',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10), // 텍스트와 그래프 간격 추가
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // 중앙 정렬
                                    children: [
                                      Container(
                                        width: 150, // 그래프의 너비 설정
                                        height: 150, // 그래프의 높이 설정
                                        child: PieChart(
                                          PieChartData(
                                            sections: getPieChartSections(
                                                analysisData[
                                                'emotion_distribution']),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20), // 간격 추가
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: getEmotionLabels(analysisData[
                                        'emotion_distribution']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // 오늘의 감정과 오늘의 키워드를 담는 컨테이너의 너비 조정
                                  FractionallySizedBox(
                                    widthFactor: 0.8, // 너비 비율을 80%로 설정
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      margin: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        // 오늘의 감정과 키워드 부분의 배경을 반투명 흰색으로 설정
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center, // 중앙 정렬
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  '오늘의 감정',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: emotionColors[
                                                    analysisData[
                                                    'most_felt_emotion']],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      analysisData[
                                                      'most_felt_emotion'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  '오늘의 키워드',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.indigo,
                                                  // 키워드 색상 (예시)
                                                  child: Center(
                                                    child: Text(
                                                      analysisData[
                                                      'most_thought_background'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(analysisData['response_message'],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}