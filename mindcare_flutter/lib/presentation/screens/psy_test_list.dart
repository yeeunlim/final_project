import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우울증 검사 결과',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DepressionTestResultsPage(),
    );
  }
}

class DepressionTestResultsPage extends StatelessWidget {
  const DepressionTestResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('우울증 검사 결과'),
      ),
      body: Row(
        children: [
          // 왼쪽 검사 목록
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade200,
              child: ListView(
                children: List.generate(10, (index) {
                  return ListTile(
                    title: Text('검사 ${index + 1}'),
                    subtitle: Text('검사 날짜: 2023-06-0${index + 1}'),
                    onTap: () {
                      // 검사 결과 상세 페이지로 이동
                    },
                  );
                }),
              ),
            ),
          ),
          // 오른쪽 검사 소개 및 새롭게 검사하기 버튼
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '우울증 검사 소개',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '우울증 검사는 당신의 정신 건강 상태를 평가하는 데 도움이 됩니다. '
                    '이 검사를 통해 현재 느끼는 감정과 상태를 확인하고, '
                    '필요한 조치를 취할 수 있습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 새롭게 검사하기 버튼 동작
                      },
                      child: const Text('새롭게 검사하기'),
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
