import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';
import 'package:mindcare_flutter/presentation/widgets/confirm_dialog.dart';


import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';

class StressTestResults extends StatefulWidget {
  const StressTestResults({super.key});

  @override
  _StressTestResultsState createState() => _StressTestResultsState();
}

class _StressTestResultsState extends State<StressTestResults> {
  List<dynamic> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final results = await PsyCommon.fetchTestResults('Stress');
    setState(() {
      testResults = results;
      isLoading = false;
    });
  }

  Future<void> _deletePsyTest(String id) async {
    await PsyCommon.deleteTestResult(id);
    setState(() {
      // 모달 창 닫고, 
      Navigator.of(context).pop();
       _fetchTestResults();
    });
  }

  void _showConfirmDialog(String id) {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            _deletePsyTest(id);
          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          message: '이 심리검사 기록을 정말로 삭제하시겠습니까?', // 메시지 전달
          confirmButtonText: '예', // 확인 버튼 텍스트
          cancelButtonText: '아니오', // 취소 버튼 텍스트
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
                    child:  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // 배경색 설정
                          borderRadius: BorderRadius.circular(12), // 둥근 테두리 설정
                          border: Border.all(color: Colors.grey.shade300, width: 0.5), // 테두리 설정
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
                                  '스트레스 자각 척도 검사란?',
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
                            '스트레스 자각 척도 (Perceived Stress Scale, PSS)\n'
                            'PSS 는 최근 1개월 동안 피험자가 지각한 스트레스 경험에 대해'
                            ' likert 척도로 평가하는 설문 방법으로 1983년 14문항으로 개발되었으나'
                            ' 1988년 Cohen 등에 의해 10개의 문항 0~3점으로 평가하는 방법으로 변경되어 '
                            ' 신뢰도와 타당도 역시 검증되었습니다. '
                            '\n본 검사는 최근 1개월 동안 당신이 느끼고 생각한 것에 대한 것입니다.'
                            '\n각 문항에 해당하는 내용을 얼마나 자주 느꼈는지 표기해 주십시오.'
                            '\n\n17점 이하 : 정상군 입니다.'
                            '\n18~ 25점 : 경도의 스트레스군 입니다.'
                            '\n26점 이상 : 고도의 스트레스군 입니다.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              onPressed: (){
                                PsyCommon.showConfirmDialog(context, 'stress');
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
                    ),
                  ),
                   // 왼쪽 검사 목록
                  Expanded(
                    flex: 3,
                    child:  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5), // 배경색 설정
                        borderRadius: BorderRadius.circular(12), // 둥근 테두리 설정
                        border: Border.all(color: Colors.grey.shade300, width: 0.5), // 테두리 설정
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
                              ' ▶ 스트레스 자각 검사 리스트',
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
                  ),
                  // 오른쪽 검사 소개 및 새롭게 검사하기 버튼
                ],
                
              ),
            ),
          ),
        ],
      ),
    );
  }
}