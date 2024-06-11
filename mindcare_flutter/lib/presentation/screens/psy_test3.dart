import 'package:flutter/material.dart';
import '../../core/constants/urls.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/psy_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '심리검사',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const psyServey3(),
    );
  }
}

class psyServey3 extends StatefulWidget {
  const psyServey3({super.key});

  @override
  _psyServey3State createState() => _psyServey3State();
}

class _psyServey3State extends State<psyServey3> {
  final PageController _pageController = PageController();
  final List<String> questions = [
    "당신은 방금 구입한 기계의 포장을 풀어 플러그를 꽂았으나 작동하지 않을 때",
    "당신을 제멋대로 대한 수리공에 의해 바가지를 썼을 때",
    "다른이의 행동은 주목되지 않고 당신만 유독 지적 당할 때",
    "당신 차를 진흙에 빠뜨렸을 때",
    "당신이 사람들에게 이야기 해도 그들이 대답하지 않을 때",
    "어떤 이들은 그렇지도 않으면서 대단한 사람인 것처럼 한다.",
    "식당에서 당신이 식탁으로 컵 4개를 운반하려고 애쓸 때 누가 당신과 부딪쳐 커피를 쏟았다.",
    "당신이 옷을 걸어 놓았는데 누군가 그것을 쳐서 바닥에 넘어뜨렸다.",
    "당신이 어느 가게에 들어선 순간부터 점원에게 구박당한다.",
    "놀림과 조롱을 당할 때",
    "당신이 어떤 이와 함께 어떤 곳에 가기로 약속했지만 그사람이 마지막 순간에 당신을 바람맞힐 때",
    "교통신호등에서 당신 차의 엔진이 꺼진 판에 당신 뒤 차의 사람이 경적을 계속 울려 댈 때",
    "당신이 회전을 잘 하지 못할 때 어떤이가 당신에게 '어디에서 운전을 배웠어?' 하며 소리친다.",
    "어떤 이가 실수하고는 당신 탓으로 돌린다.",
    "당신은 집중하려 애쓰지만 당신 근처의 사람이 발을 토닥거린다.",
    "당신은 중요한 책이나 물건을 빌려주었으나 그 사람이 돌려주지 않는다.",
    "당신은 바빴다. 그런데 당신과 함께 사는 사람이 당신이 그 사람과 함께 하기로 동의한 중요한 것을 어떻게 잊었느냐고 불평하기 시작한다.",
    "당신은 당신의 느낌을 표현할 기회를주지 않는 동료나 상대와 중요한 일을 토론하려고 애쓴다.",
    "별로 아는 바도 없으면서 어떤 화제에 대해 논쟁하기를 고집하는 어떤 이와 신은 토론하고 있다.",
    "어떤 이가 당신과 다른 이의 논쟁에 기어든다.",
    "당신은 급히 어떤 곳에 가야 한다. 그러나 당신 앞 차는 속도 제한 70Km의 도로에서 약 40Km로 가고 있는데다가 당신은 앞지르기조차도 할 수 없다.",
    "껌 덩어리를 밟았다.",
    "당신은 적은 무리의 사람들을 지나치다가 그들에게 조롱당한다.",
    "어떤곳에 급히 가려다가 뾰족한 물건에 좋은 바지가 찢어진다.",
    "당신은 하나 남은 동전으로 캔을 빼려 했으나 캔은 안 나오고 동전을 삼켰다.",
  ];

  final List<String> choiceLabels = [
    "거의 화를\n느끼지\n않는다",
    "조금\n화가 난다",
    "어느 정도\n화가 난다",
    "꽤\n화가 난다",
    "대단히\n화가 난다"
  ];

  final Map<int, int> answers = {};
  bool showResult = false;
  String resultMessage = "";
  int totalScore = 0;
  
  void _showResultPage() {
    setState(() {
      totalScore = answers.values.fold(0, (sum, item) => sum + item);
      if (totalScore <= 45) {
        resultMessage = "일반적으로 체험하는 분노와 괴로움의 양이 상당히 적다.\n소수의 사람만이 이에 해당된다.";
      } else if (totalScore <= 55) {
        resultMessage = "보통 사람들보다 상당히 평화스럽다.";
      } else if (totalScore <= 75) {
        resultMessage = "보통 사람들처럼 적당히 분노를 표출한다.";      
      } else {
        resultMessage = "보통 사람보다 흥분하기 쉬우며 화를 더 잘 내는 편이다.\n흔히 성난 방법으로 인생의 많은 괴로움에 반응한다.";
      }

      // 결과를 Django 서버에 저장
      PsyTest.SubmitSurveyResult(totalScore, resultMessage, 'anger');

      // 결과 페이지를 표시하도록 상태 업데이트
      showResult = true;
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
          Center( // Center를 사용하여 Container가 화면 중앙에 위치하도록 함
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: showResult ? buildResultPage() : buildQuestionPageView(),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (showResult) {
            // 결과 페이지가 표시된 상태에서는 아무 작업도 하지 않음
            return;
          }

          int currentPage = _pageController.page!.toInt();
          // int start = currentPage * 9;
          // int end = (currentPage + 1) * 9;
          int start = 0;
          int end = 0;
          if (currentPage == 0) {
            start = 0;
            end = 9;
          } else if (currentPage == 1) {
            start = 9;
            end = 17;
          } else if (currentPage == 2) {
            start = 17;
            end = 25;
          }

          bool allAnswered = true;
          for (int i = start; i < end; i++) {
            if (answers[i] == null) {
              allAnswered = false;
              break;
            }
          }

          if (allAnswered) {
            if (currentPage < 2) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            } else {
               _showResultPage();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('모든 문항에 답변을 선택해주세요.'),
              ),
            );
          }
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget buildQuestionPageView() {
    return PageView(
      controller: _pageController,
      children: [
        buildQuestionPage(0, 9),
        buildQuestionPage(9, 17),
        buildQuestionPage(17, 25),
      ],
    );
  }

  Widget buildQuestionPage(int start, int end) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: TableBorder.all(color : Colors.grey.shade300, style: BorderStyle.solid,
                  width: 0.5),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FixedColumnWidth(70),
            2: FixedColumnWidth(70),
            3: FixedColumnWidth(70),
            4: FixedColumnWidth(70),
            5: FixedColumnWidth(70),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle, // 세로 정렬
          children: [
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '질문사항',
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
      ),
    );
  }

  Widget buildResultPage() {
    return Center(
      child: Text(
        '총 점수: $totalScore\n$resultMessage',
        style: const TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
