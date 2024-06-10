import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DiaryPage(),
    );
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _response = '오늘은 무슨 일이 있었나요?';

  Future<void> _getResponse(String input) async {
    print("Requesting with input: $input"); // 로그 추가
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/chatbot_diary/chatbot/?s=$input')); // ip주소 수정
      print("Response status: ${response.statusCode}"); // 로그 추가
      print("Response body: ${response.body}"); // 로그 추가

      if (response.statusCode == 200) {
        setState(() {
          _response = json.decode(response.body)['answer'];
        });
      } else {
        setState(() {
          _response = 'Error: Unable to get response from server';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff110f12),
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () async {
        //       await AuthHelpers.logout(context);
        //       setState(() {
        //         isAuthenticated = false;
        //       });
        //       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
        //     },
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/main_page.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 1000,
              height: 700,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white70.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/normal_rabbit.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _response,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 400,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '오늘의 감정을 여기에 적어주세요...',
                              hintStyle: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _getResponse(value);
                                _controller.clear();
                                _focusNode.requestFocus();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _getResponse(_controller.text);
                                _controller.clear();
                                _focusNode.requestFocus();
                              }
                            },
                            child: const Text('저장'),
                          ),
                        ],
                      ),
                    ],
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

