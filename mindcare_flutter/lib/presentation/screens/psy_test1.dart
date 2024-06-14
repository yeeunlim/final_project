import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';
import 'package:mindcare_flutter/presentation/widgets/alert_dialog.dart';
import 'package:mindcare_flutter/presentation/widgets/confirm_dialog.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_test_result.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test1_home.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';


class psyServey1 extends StatefulWidget {
  const psyServey1({super.key});

  @override
  _psyServey1State createState() => _psyServey1State();
}

class _psyServey1State extends State<psyServey1> {
  
  final PageController _pageController = PageController();
  final List<String> questions = [
    "남들에게 불안하게 보이지 말아야 한다.",
    "집중이 잘 안되면, 이러다가 미치는 것은 아닌가 걱정한다.",
    "몸이 떨리거나 휘청거리면, 겁이 난다.",
    "기절할 것 같으면, 겁이 난다.",
    "감정 조절은 잘 하는 것이 중요하다.",
    "심장이 빨리 뛰면 겁이 난다.",
    "배에서 소리가 나면 깜짝 놀란다.",
    "속이 매스꺼워지면 겁이 난다.",
    "심장이 빨리 뛰는 것이 느껴지면 심장마비가 오지 않을까 걱정된다.",
    "숨이 가빠지면, 겁이 난다.",
    "뱃속이 불편해지면, 심각한 병에 걸린 것은 아닌가 걱정된다.",
    "어떤 일을 할 때 집중이 안되면, 겁이 난다.",
    "내가 떨면, 다른 사람들이 알아 챈다.",
    "몸에 평소와 다른 감각이 느껴지면, 겁이 난다.",
    "신경이 예민해지면, 정신적으로 문제가 생긴 것은 아닌가 걱정된다.",
    "신경이 날카로워 지면, 겁이 난다.",
  ];
  
  final List<String> choiceLabels = [
    "전혀\n그렇지 않다",
    "약간 그러한\n편이다",
    "중간\n이다",
    "꽤\n그러한\n편이다",
    "매우 그렇다"
  ];

  final Map<int, int> answers = {};
  bool showResult = false;
  String resultMessage = "";
  int totalScore = 0;

  void _showResultPage() {
    setState(() {
      totalScore = answers.values.fold(0, (sum, item) => sum + item);
      if (totalScore <= 15) {
        resultMessage = "불안 자극에 민감하지 않습니다.";
      } else if (totalScore <= 20) {
        resultMessage = "불안 자극에 약간 민감하게 반응합니다.";        
      } else if (totalScore <= 24) {
        resultMessage = "불안 자극에 상당히 민감하게 반응합니다.";
      } else {
        resultMessage = "불안 자극에 매우 민감하게 반응합니다.";
      }

      // 결과를 Django 서버에 저장
      PsyCommon.SubmitSurveyResult(totalScore, resultMessage, 'anxiety');

      showResultDialog(context, 'anxiety', totalScore.toDouble(), resultMessage, '',);

      // 결과 페이지를 표시하도록 상태 업데이트
      showResult = true;
    });
  }

  void _showAlertDialog() {
    AlertDialogHelper.showAlert(
      context,
      '심리검사',
      '모든 문항에 답변을 선택해주세요.',
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnxietyTestResults()),
            );
          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          message: '심리검사를 취소 하시겠습니까?', // 메시지 전달
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
          Center( // Center를 사용하여 Container가 화면 중앙에 위치하도록 함
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              // child: showResult ? buildResultPage() : buildQuestionPageView(),
              child: buildQuestionPageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionPageView() {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              buildQuestionPage(0, 8),
              buildQuestionPage(8, 16),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: 'backButton', // Hero 태그를 고유하게 설정
              onPressed: () {
                if (_pageController.page == 0) {
                  _showConfirmDialog();
                } else {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: const Icon(Icons.arrow_back),
            ),
            FloatingActionButton(
              heroTag: 'nextButton', // Hero 태그를 고유하게 설정
              onPressed: () {
                if (showResult) {
                  // 결과 페이지가 표시된 상태에서는 아무 작업도 하지 않음
                  return;
                }

                int currentPage = _pageController.page!.toInt();
                int start = currentPage * 8;
                int end = (currentPage + 1) * 8;

                bool allAnswered = true;
                for (int i = start; i < end; i++) {
                  if (answers[i] == null) {
                    allAnswered = false;
                    break;
                  }
                }

                if (allAnswered) {
                  if (currentPage < 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    _showResultPage();
                  }
                } else {
                  _showAlertDialog();
                }
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildQuestionPage(int start, int end) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [          
            Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // 배경색 설정
              borderRadius: BorderRadius.circular(12), // 둥근 테두리 설정
              border: Border.all(color: Colors.grey.shade300, width: 0.5), // 테두리 설정
            ),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade600, width: 0.3),
                verticalInside: BorderSide(color: Colors.grey.shade600, width: 0.3),
                // top, bottom, left, right border can be customized here if needed
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                // 0: FixedColumnWidth(350),
                1: FixedColumnWidth(50),
                2: FixedColumnWidth(50),
                3: FixedColumnWidth(50),
                4: FixedColumnWidth(50),
                5: FixedColumnWidth(50),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle, // 세로 정렬
              children: [
                TableRow(
                  decoration: const BoxDecoration(),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '[불안 민감도 검사] 질문사항',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...choiceLabels.map((choice) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            choice,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                for (int i = start; i < end && i < questions.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(questions[i]),
                      ),
                      ...List<Widget>.generate(choiceLabels.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Radio<int>(
                            value: index,
                            groupValue: answers[i],
                            onChanged: (int? value) {
                              setState(() {
                                answers[i] = value!;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          )
          ],
        ),
      ),
    );
  }
}