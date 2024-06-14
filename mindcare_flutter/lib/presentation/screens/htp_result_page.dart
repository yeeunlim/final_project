import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/screens/htp_main_page.dart';

class ResultPage extends StatefulWidget {
  final String token;
  final List<String> drawingIds;
  final List<Map<String, dynamic>> results;

  ResultPage({required this.token, required this.drawingIds, required this.results});

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
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HTP 검사결과',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        // 좌측 이미지 박스
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 300,
                            color: Colors.white,
                            child: widget.results[_currentIndex]['result_image_url'] != null
                              ? Image.network(widget.results[_currentIndex]['result_image_url'])
                              : Container(),
                          ),
                        ),
                        SizedBox(width: 10),
                        // 우측 텍스트 박스
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 300,
                            padding: EdgeInsets.all(16.0),
                            color: Colors.grey[200],
                            child: SingleChildScrollView(
                              child: Text(
                                '${widget.results[_currentIndex]['result']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward),
                    SizedBox(width: 10),
                    Text(_currentIndex < widget.results.length - 1 ? '다음' : '완료'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
