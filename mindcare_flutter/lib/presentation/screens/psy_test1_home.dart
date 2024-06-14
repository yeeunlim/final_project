import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';
import 'package:mindcare_flutter/presentation/widgets/confirm_dialog.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_test_result.dart';


import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';


class AnxietyTestResults extends StatefulWidget {
  const AnxietyTestResults({super.key});

  @override
  _AnxietyTestResultsState createState() => _AnxietyTestResultsState();
}

class _AnxietyTestResultsState extends State<AnxietyTestResults> {
  List<dynamic> testResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final results = await PsyCommon.fetchTestResults('anxiety');
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

  void _showConfirmDeleteDialog(String id) {
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8, // 고정된 높이 설정
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
                                      const Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 20, // 텍스트를 그림의 오른쪽 아래에 맞추기 위한 공간
                                            ),
                                            Text(
                                              '불안 민감도 검사란?',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Flexible(
                                          child:Text(
                                            '\n불안 민감성 척도(Anxiety Sensitivity Inventroy:ASI)\n'
                                            '이 척도는 불안과 관련된 증상을 경험할 때 그 증상으로 인해 '
                                            '얼마나 두렵고 염려되는가를 평가하는 검사로서 불안증상에 대해 '
                                            '개인이 가지고 있는 두려움을 반영합니다.\n'
                                            '불안 민감성은 공황 발작의 예언 변인이자 공포 조건화 가능성을 '
                                            '증가시키는 요인으로 알려져 있으며, 시간에 걸쳐 안정적인 '
                                            '성격 특성에 가까운 것으로 보고 되었습니다.'
                                            '\n불안의 결과에 대해 얼마나 두려워하는지를 묻는 '
                                            '총 16문항으로 구성, 각 문항에 대해 0~4 점 척도로 평정하는 검사입니다.'
                                            '\n\n  0~15점 : 불안 자극에 민감하지 않습니다.'
                                            '\n16~20점 : 불안 자극에 약간 민감하게 반응합니다.'
                                            '\n21~24점 : 불안 자극에 상당히 민감하게 반응합니다.'
                                            '\n25~64점 : 불안 자극에 매우 민감하게 반응합니다.\n\n',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: (){
                                              PsyCommon.showConfirmDialog(context, 'anxiety');
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

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 왼쪽 검사 목록
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                                  ' ▶ 불안 민감도 검사 결과',
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
                                            subtitle: Text('점수: ${result['total_score']}'),
                                            onTap: () {
                                              // _showResultDialog(result);
                                              showResultDialog(context, result['survey_type'], result['total_score'], result['result'], result['id'].toString(), _showConfirmDeleteDialog);
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