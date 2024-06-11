import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/emotion_pie_chart.dart';
import '../widgets/confirm_dialog.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';
import 'package:mindcare_flutter/core/services/api_service.dart';
import 'package:mindcare_flutter/core/constants/image_urls.dart';

class DailyAnalysisScreen extends StatefulWidget {
  const DailyAnalysisScreen({
    super.key,
    required this.entryDate,
    required this.entryData,
    required this.diaryText,
  });

  final String entryDate;
  final Map<String, dynamic> entryData;
  final String diaryText;

  @override
  _DailyAnalysisScreenState createState() => _DailyAnalysisScreenState();
}

class _DailyAnalysisScreenState extends State<DailyAnalysisScreen> {
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.diaryText);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _deleteDiaryEntry(BuildContext context) async {
    try {
      await DailyAnalysisService.deleteDiaryEntry(widget.entryData['id']);
      Navigator.pop(context); // 일기 삭제 후 이전 화면으로 돌아갑니다.
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _updateDiaryEntry(BuildContext context) async {
    try {
      await DailyAnalysisService.updateDiaryEntry(
        widget.entryData['id'],
        _editController.text,
        widget.entryDate,
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            _deleteDiaryEntry(context); // 일기 삭제
          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          message: '정말로 이 일기를 삭제하시겠습니까?', // 메시지 전달
          confirmButtonText: '삭제', // 확인 버튼 텍스트
          cancelButtonText: '취소', // 취소 버튼 텍스트
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Null 값에 대한 기본 처리
    final emotionDistribution = widget.entryData['emotion_distribution'] ?? {};
    final mostFeltEmotion = widget.entryData['most_felt_emotion'] ?? 'Unknown';
    final mostThoughtBackground = widget.entryData['most_thought_background'] ?? 'Unknown';
    final responseMessage = widget.entryData['response_message'] ?? 'No response available';

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      border: _isEditing ? Border.all(color: Colors.grey) : null, // 수정 중일 때 border 추가
                                      borderRadius: BorderRadius.circular(12), // 원하는 값으로 조정
                                    ),
                                    child: SingleChildScrollView(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0), // 상하 여백 추가
                                        child: TextField(
                                          controller: _editController,
                                          maxLines: null, // 텍스트가 필요한 만큼의 라인을 차지하도록 null로 설정
                                          decoration: const InputDecoration(
                                            border: InputBorder.none, // 테두리 없음
                                            hintText: '일기 내용을 입력하세요.',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_isEditing) {
                                          print('Context value when pressing the Update button: $context');
                                          _updateDiaryEntry(context);
                                        } else {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        }
                                      },
                                      child: Text(_isEditing ? '저장' : '수정'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showDeleteConfirmDialog(context);
                                      },
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              ],
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
                                  EmotionPieChart(
                                    emotionDistribution: emotionDistribution,
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
                                        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                                    color: emotionColors[mostFeltEmotion],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      mostFeltEmotion,
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
                                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                                      mostThoughtBackground,
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
                                  Text(
                                    responseMessage,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
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
