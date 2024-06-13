import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_drawer.dart';
import 'package:mindcare_flutter/presentation/widgets/custom_app_bar.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_common.dart';
import 'package:mindcare_flutter/presentation/widgets/alert_dialog.dart';
import 'package:mindcare_flutter/presentation/widgets/confirm_dialog.dart';
import 'package:mindcare_flutter/presentation/widgets/psy_test_result.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2_home.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';

class psyServey2 extends StatefulWidget {
  const psyServey2({super.key});

  @override
  _psyServey2State createState() => _psyServey2State();
}

class _psyServey2State extends State<psyServey2> {
  final PageController _pageController = PageController();
  final List<String> questions = [
    "예상치 못한 일 때문에 화가 난 적이 있습니까?",
    "생활하면서 중요한 일들을 통제할 수 없다고 느낀 적이 있습니까?",
    "신경이 예민해지고 스트레스를 받은 적이 있습니까?",
    "통제할 수 없는 일 때문에 화가 난 적이 있습니까?",
    "힘든 일이 너무 많이 쌓여서 도저히 감당할 수 없다고 느낀 적이 있습니까?",
    "당신이 해야만 하는 모든 일을 감당할 수 없다고 느낀 적이 있습니까?",
    "개인적인 문제들을 다루는 능력에 대해 자신감을 느낀 적이 있습니까?",
    "당신이 원하는 방식으로 일이 진행되고 있다고 느낀 적이 있습니까?",
    "일상생활에서 겪는 불안감과 초조함을 통제할 수 있었습니까?",
    "일들이 어떻게 돌아가는 지 잘 알고 있다고 느낀 적이 있었습니까?",
  ];
  
  final List<String> choiceLabels = [
    "아니다",
    "가끔\n그렇다",
    "자주\n그렇다",
    "항상\n그렇다"
  ];

  final Map<int, int> answers = {};
  bool showResult = false;
  String resultMessage = "";
  int totalScore = 0;

  int getScore() {
    int totalScore = 0;
    answers.forEach((index, score) {
      if (index < 6) {
        // 아니다 0점, 가끔 그렇다 1점, 자주 그렇다 2점, 항상 그렇다 3점
        totalScore += score; // 1~6번 질문의 점수
      } else {
        // 아니다 3점, 가끔 그렇다 2점, 자주 그렇다 1점, 항상 그렇다 0점
        int newScore = 0;
        switch(score) {
          case 0:
            newScore = 3;
          case 1:
            newScore = 2;
          case 2:
            newScore = 1;
          case 3:
            newScore = 0;          
        }
        totalScore += newScore; 
      }
    });

    return totalScore;   
  }

  void _showResultPage() {
    setState(() {
      totalScore = getScore();

      if (totalScore <= 17) {
        resultMessage = "스트레스가 거의 없는 정상군 입니다.";
      } else if (totalScore <= 25) {
        resultMessage = "경도의 스트레스군 입니다.";
      } else {
        resultMessage = "고도의 스트레스군 입니다.";
      }

      // 결과를 Django 서버에 저장
      PsyCommon.SubmitSurveyResult(totalScore, resultMessage, 'stress');

      showResultDialog(context, 'stress', totalScore.toDouble(), resultMessage, '',);


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
              MaterialPageRoute(builder: (context) => const StressTestResults()),
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
              buildQuestionPage(0, 10),
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
                int start = currentPage * 10;
                int end = (currentPage + 1) * 10;

                bool allAnswered = true;
                for (int i = start; i < end; i++) {
                  if (answers[i] == null) {
                    allAnswered = false;
                    break;
                  }
                }

                if (allAnswered) {
                  if (currentPage < 0) {
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
                        '[스트레스 자각 검사] 질문사항',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...choiceLabels.map((choice) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            choice,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize:12, fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                for (int i = start; i < end; i++)
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
                                answers[i] = index;
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
