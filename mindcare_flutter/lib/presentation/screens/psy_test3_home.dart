import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';


import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';


class AngerTestResults extends StatefulWidget {
  const AngerTestResults({super.key});

  @override
  _AngerTestResultsState createState() => _AngerTestResultsState();
}

class _AngerTestResultsState extends State<AngerTestResults> {
  List<dynamic> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final results = await PsyCommon.fetchTestResults('anger');
    setState(() {
      testResults = results;
      isLoading = false;
    });
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
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 왼쪽 검사 목록
                  Expanded(
                    flex: 2,
                    child: Container(
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
                              ' ▶ 노바코 분노 검사 리스트',
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
                                  return ListTile(
                                    title: Text('검사 ${index + 1} [${PsyCommon.formatDate(result['created_at'])}]'),
                                    subtitle: 
                                    Text('점수: ${result['total_score']}'),
                                    // style: TextStyle(
                                    //   fontSize: 24,
                                    //   fontWeight: FontWeight.bold,
                                    // ),                                    
                                    onTap: () {
                                      // 검사 결과 상세 페이지로 이동
                                    },
                                  );
                                },
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 오른쪽 검사 소개 및 새롭게 검사하기 버튼
                  Expanded(
                    flex: 3,
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
                            const SizedBox(
                              width: 10, // 그림과 텍스트 사이의 간격
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20, // 텍스트를 그림의 오른쪽 아래에 맞추기 위한 공간
                                ),
                                Text(
                                  '노바코 분노 척도 검사란?',
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
                            '노바코 분노 척도 검사 (Novaco Anger Scale: NAS)\n'
                            '분노를 촉발하는 상황에 대한 반응을 측정하는 척도로'
                            " '제멋대로 행동한 수리공에게 바가지를 썻을 때', '당신이 걸어 놓은 옷을 누가 쳐서 바닥에 넘어뜨렸을 때' 등"
                            ' 일상생활에서 흔히 일어나는 분노를 유발하는 상황에 대한 분노 수준의 정도를 측정하는 척도 입니다.'
                            '\n총 25문항으로 되어 있으며, 0~4점 척도로 평가합니다.'
                            '\n\n45점 이하 : 침착한 사람군에 속하는 사람입니다.'
                            '\n46~ 55점 : 평균적인 사람보다 평화로운 사람입니다.'
                            '\n56~ 75점 : 보통의 여느 사람들처럼 적당한 분노를 표출합니다.'
                            '\n76~ 85점 : 보통 사람보다 화를 더 내는 편입니다.'
                            '\n85점 이상 : 종종 격렬한 분로를 표출 한 후 그 감정이 쉽게 사라지지 않는 편입니다.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              onPressed: (){
                                PsyCommon.showConfirmDialog(context, 'anger');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: secondaryColor,
                              ),                              
                              child: const Text('검사하기'),
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