import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String message) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/chatbot_diary/chatbot/?s=$message'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _responseController.text = responseData['chatbot_response'];
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
        Uri.parse('http://127.0.0.1:8000/api/chatbot_diary/diary_analysis/'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미아에게 마음을 터 놓으세요.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              controller: _inputController,
              focusNode: _inputFocusNode,
              decoration: const InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.go,
              onChanged: (_) {
                setState(() {}); // 텍스트가 변경될 때마다 상태 업데이트
              },
              onSubmitted: (text) {
                _inputFocusNode.requestFocus(); // 다음 줄에 포커스를 이동
                sendMessage(text);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                saveDiary();
              },
              child: const Text('일기 저장'),
            ),
            const SizedBox(height: 60),
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Chatbot Response',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const AnalysisScreen({Key? key, required this.analysisData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 감정 분석'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '감정 분포',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(analysisData['emotion_distribution'].toString()),
            const SizedBox(height: 10),
            const Text(
              '배경 분포',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(analysisData['background_distribution'].toString()),
            const SizedBox(height: 10),
            const Text(
              '가장 많이 느낀 감정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(analysisData['most_felt_emotion']),
            const SizedBox(height: 10),
            const Text(
              '가장 많이 생각한 배경',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(analysisData['most_thought_background']),
            const SizedBox(height: 10),
            const Text(
              '챗봇 응답',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(analysisData['response_message']),
          ],
        ),
      ),
    );
  }
}
