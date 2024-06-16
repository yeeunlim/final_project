import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import '../widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/screens/htp_main_page.dart';

class ResultPage extends StatefulWidget {
  final String token;
  final List<String> drawingIds;
  final List<Map<String, dynamic>> results;

  const ResultPage({super.key, required this.token, required this.drawingIds, required this.results});

  @override
  State<StatefulWidget> createState() {
    return _ResultPageState();
  }
}

class _ResultPageState extends State<ResultPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(token: widget.token),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(ImageUrls.mainPageBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  constraints: const BoxConstraints(maxWidth: 800), // 겉박스 최대 너비 제한
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HTP 검사결과 - ${widget.results[_currentIndex]['type'].toString().toUpperCase()}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // 좌측 이미지 박스
                          Expanded(
                            flex: 1,
                            child: AspectRatio(
                              aspectRatio: 1.0, // 정사각형 비율 유지
                              child: Container(
                                color: Colors.white,
                                child: widget.results[_currentIndex]['result_image_url'] != null
                                    ? Image.network(
                                        widget.results[_currentIndex]['result_image_url'],
                                        fit: BoxFit.cover, // 이미지를 박스에 맞게 맞춤
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 우측 텍스트 박스
                          Expanded(
                            flex: 1,
                            child: AspectRatio(
                              aspectRatio: 1.0, // 정사각형 비율 유지
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                color: Colors.grey[200],
                                child: SingleChildScrollView(
                                  child: Text(
                                    '${widget.results[_currentIndex]['result']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // 텍스트 박스와 버튼 사이에 여백 추가
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < widget.results.length - 1) {
                              setState(() {
                                _currentIndex++;
                              });
                            } else {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HTPMainPage(token: widget.token)),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward),
                              const SizedBox(width: 10),
                              Text(_currentIndex < widget.results.length - 1 ? '다음' : '완료'),
                            ],
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
      ),
    );
  }
}
