import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'htp_second_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';

import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';

class HTPMainPage extends StatefulWidget {
  final String token;

  const HTPMainPage({Key? key, required this.token}) : super(key: key);
  
  @override
  _HTPTestResultsState createState() => _HTPTestResultsState(token: token);
} 

class _HTPTestResultsState extends State<HTPMainPage> {
  final String token;

  _HTPTestResultsState({required this.token});

  List<dynamic> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final response = await http.get(
      Uri.parse('$htpTestUrl/results/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        testResults = json.decode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showResultDialog(dynamic result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('검사 결과'),
          content: Text(result['result']),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () async {
                final response = await http.delete(
                  Uri.parse('$htpTestUrl/results/${result['id']}/'),
                  headers: {'Authorization': 'Bearer $token'},
                );
                if (response.statusCode == 204) {
                  setState(() {
                    testResults.remove(result);
                  });
                  Navigator.of(context).pop();
                } else {
                  // 오류 처리
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteResult(int id) async {
    final response = await http.delete(
      Uri.parse('$htpTestUrl/results/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        testResults.removeWhere((result) => result['id'] == id);
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(token: token),
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
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Text(
                                        'HTP 검사란?',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                '벅(Buck, 1948)이 고안한 투사적 그림검사로서 집, 나무, 사람을 각각 그리게 하여 '
                                '내담자의 성격, 행동 양식 및 대인관계를 파악할 수 있습니다. 피험자의 성격적 특징뿐만 아니라 지적 수준을 평가하고 '
                                '또한 정신장애 및 신경증의 부분적 양상을 파악하는데 널리 사용되기도 합니다.',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => HTPSecondPage(token: token)),
                                    );
                                  },
                                  child: Text('다음'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (testResults.isEmpty)
                              const Text(
                                '검사 기록이 없습니다.',
                                style: TextStyle(fontSize: 18),
                              )
                            else
                              const Text(
                                ' ▶ HTP 검사 리스트',
                                style: TextStyle(fontSize: 18),
                              ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                      itemCount: testResults.length,
                                      itemBuilder: (context, index) {
                                        final result = testResults[index];
                                        return GestureDetector(
                                          onTap: () => _showResultDialog(result),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                                            child: ListTile(
                                              title: Text('검사 ${index + 1} [${result['created_at']}]'),
                                              subtitle: Text('검사항목: ${result['type']}'),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
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
