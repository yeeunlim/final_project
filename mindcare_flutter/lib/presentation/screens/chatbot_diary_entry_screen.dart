import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/api_service.dart';
import 'package:mindcare_flutter/presentation/widgets/common_button.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/loading_screen.dart';

import '../../core/constants/urls.dart';
import '../widgets/confirm_dialog.dart';

class ChatbotDiaryEntryScreen extends StatefulWidget {
  final String? selectedDate;

  const ChatbotDiaryEntryScreen({super.key, this.selectedDate});

  @override
  _ChatbotDiaryEntryScreenState createState() => _ChatbotDiaryEntryScreenState();
}

class _ChatbotDiaryEntryScreenState extends State<ChatbotDiaryEntryScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String _chatbotResponse = "오늘은 무슨 일이 있었나요?";
  bool _isLoading = false; // 로딩 상태 관리
  late String selectedDate; // 선택된 날짜를 저장

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now().toIso8601String().split('T')[0];
    print('Selected date: $selectedDate');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    try {
      if (args == null) {
        print('No arguments received, using default date');
        selectedDate = DateTime.now().toIso8601String().split('T')[0];
      } else if (args is Map && args.containsKey('selectedDate')) {
        selectedDate = args['selectedDate'];
        print('Selected date received: $selectedDate');
      } else if (args is String) {
        final token = args;
        print('Token received: $token');
        selectedDate = DateTime.now().toIso8601String().split('T')[0];
      } else {
        throw Exception('Invalid arguments received');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String message) async {
    try {
      final responseData = await ChatbotService.sendMessage(message);
      setState(() {
        _chatbotResponse = responseData['chatbot_response'];
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> saveDiary() async {
    final diaryText = _inputController.text;
    final diaryEntryService = DiaryEntryService();

    setState(() {
      _isLoading = true; // 로딩 시작
      print('saveDiary started with diaryText: $diaryText, entryDate: $selectedDate'); // 시작 로그
    });
    try {
      final responseData = await diaryEntryService.createDiaryEntry(diaryText, selectedDate);

      // responseData가 null인 경우 처리
      if (responseData == null) {
        throw Exception('Failed to create diary entry: No response data received');
      }

      print('Received responseData: $responseData');
      print('Navigating to DailyAnalysisScreen with entryData: $responseData, entryDate: $selectedDate, diaryText: $diaryText');
      Navigator.pushNamed(
        context,
        '/daily_analysis',
        arguments: {
          'entryData': responseData,
          'entryDate': selectedDate,
          'diaryText': diaryText,
        },
      );
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }



  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            saveDiary(); // 일기 저장
          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          message: '저장하시겠습니까?', // 메시지 전달
          confirmButtonText: '저장', // 확인 버튼 텍스트
          cancelButtonText: '취소', // 취소 버튼 텍스트
        );
      },
    );
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
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        ImageUrls.normalRabbit,
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 100,
                            maxWidth: 500,
                          ),
                          child: Text(
                            _chatbotResponse,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(20.0),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: _inputController,
                                  focusNode: _inputFocusNode,
                                  decoration: const InputDecoration(
                                    hintText: '미아에게 마음을 터놓으세요.',
                                    border: InputBorder.none,
                                  ),
                                  textInputAction: TextInputAction.go,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  onSubmitted: (text) {
                                    _inputFocusNode.requestFocus();
                                    final lines = text.split('\n');
                                    if (lines.isNotEmpty) {
                                      sendMessage(lines.last);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CommonButton(
                                text: '저장',
                                onPressed: _showConfirmDialog, // 저장 버튼 클릭 시 다이얼로그 표시
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LoadingScreen(
            isLoading: _isLoading,
            upperText: '미아가 일기를 분석하고 있습니다.',
          ),
        ],
      ),
    );
  }
}
