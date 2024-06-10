import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../widgets/common_button.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/confirm_dialog.dart';
import 'daily_analysis_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              analysisData: responseData,
              diaryText: diaryText, // 일기 텍스트를 전달
            ),
          ),
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
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
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
                // AWS S3에서 이미지 로드
                image: NetworkImage(ImageUrls.mainPageBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            //바깥 박스
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
                  // 챗봇 응답 row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AWS S3에서 이미지 로드
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
                          constraints: BoxConstraints(
                            minWidth: 100, // 최소 너비 설정
                            maxWidth: 500, // 최대 너비 설정
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
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        children: <Widget>[
                          // 일기 입력 폼을 담는 Container
                          Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // 배경색을 흰색으로 설정
                                  borderRadius:
                                  BorderRadius.circular(12), // 모서리를 둥글게 설정
                                ),
                                padding: const EdgeInsets.all(20.0), // 내부 여백 설정
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
                                    setState(() {}); // 텍스트가 변경될 때마다 상태 업데이트
                                  },
                                  onSubmitted: (text) {
                                    _inputFocusNode
                                        .requestFocus(); // 다음 줄에 포커스를 이동
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
                          // 저장 버튼을 오른쪽 아래에 배치
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