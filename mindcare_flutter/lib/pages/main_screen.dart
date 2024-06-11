import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/common_button.dart';
import '../widgets/confirm_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  String _chatbotResponse = "오늘은 무슨 일이 있었나요?";

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String message) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chatbot_diary/chatbot/?s=$message'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _chatbotResponse = responseData['chatbot_response'];
        });
      } else {
        print('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> saveDiary() async {
    final diaryText = _inputController.text;
    final entryDate = DateTime.now().toIso8601String().split('T')[0];
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chatbot_diary/diary_analysis/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'diary_text': diaryText,
          'entry_date': entryDate,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));
        // 인자 값을 출력합니다.
        print('Navigating to DailyAnalysisScreen with entryData: $responseData, entryDate: $entryDate, diaryText: $diaryText');
        Navigator.pushNamed(
          context,
          '/daily_analysis',
          arguments: {
            'entryData': responseData,
            'entryDate': entryDate,
            'diaryText': diaryText,
          },
        );
      } else {
        print('Failed to save diary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
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
            decoration: BoxDecoration(
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
              padding: EdgeInsets.all(30.0),
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
                      SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 100,
                            maxWidth: 500,
                          ),
                          child: Text(
                            _chatbotResponse,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
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
                                padding: EdgeInsets.all(20.0),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: _inputController,
                                  focusNode: _inputFocusNode,
                                  decoration: InputDecoration(
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
                          SizedBox(height: 10),
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
        ],
      ),
    );
  }
}