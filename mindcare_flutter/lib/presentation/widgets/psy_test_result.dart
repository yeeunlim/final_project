import 'package:flutter/material.dart';

import 'package:mindcare_flutter/presentation/screens/psy_test1_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test3_home.dart';

import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

Map<String, dynamic> get_psyTestInfo(String surveyType) {
  final Color color1 = emotionColors['슬픔'] ?? Colors.red.shade50;
  final Color color2 = emotionColors['우울함'] ?? Colors.red.shade50;
  final Color color3 = emotionColors['속상함'] ?? Colors.red.shade50;
  final Color color4 = emotionColors['실망'] ?? Colors.red.shade50;
  final Color color5 = emotionColors['외로움'] ?? Colors.red.shade50;  
  if (surveyType == 'anger') {
    return {
      'survey_title': '노바코 분노 검사',
      'survey_content': '노바코 분노 척도 검사 (Novaco Anger Scale: NAS)\n'
          '분노를 촉발하는 상황에 대한 반응을 측정하는 척도로\n'
          '일상생활에서 흔히 일어나는 분노를 유발하는 상황에 대한 분노 수준의 정도를 측정하는 척도입니다.\n'
          '총 25문항으로 되어 있으며, 0~4점 척도로 평가합니다.',
      'survey_score_intro': 
        '\n\n    0~45점 : 침착한 사람군에 속하는 사람입니다.'
        '\n  46~55점 : 평균적인 사람보다 평화로운 사람입니다.'
        '\n  56~75점 : 보통의 사람들처럼 적당한 분노를 표출합니다.'
        '\n  76~85점 : 보통 사람보다 화를 더 내는 편입니다.'
        '\n85~100점 : 격렬한 분노를 표출 하고 쉽게 사라지지 않습니다.',
      'scorePositions': [0, 45, 55, 75, 85, 100],
      'sectionWidths': [0.45, 0.10, 0.20, 0.10, 0.15],
      'sectionColors': [
        color1, color2, color3, color4, color5
      ],
      'maxScore': 100.0
    };
  } else if (surveyType == 'stress') {
    return {
      'survey_title': '스트레스 자각 검사',
      'survey_content': 'PSS는 최근 1개월 동안 피험자가 지각한 스트레스 경험에 대해'
          'likert 척도로 평가하는 설문 방법으로 1983년 14문항으로 개발되었으나'
          '1988년 Cohen 등에 의해 10개의 문항 0~3점으로 평가하는 방법으로 변경되어 '
          '신뢰도와 타당도 역시 검증되었습니다. ',
      'survey_score_intro': 
          '\n\n  0~17점 : 스트레스가 거의 없는 정상군 입니다.'
          '\n18~25점 : 경도의 스트레스군 입니다.'
          '\n26~30점 : 고도의 스트레스군 입니다.',
      'scorePositions': [0, 17, 25, 30],
      'sectionWidths': [0.567, 0.267, 0.166],
      'sectionColors': [
        color1, color3, color4
      ],
      'maxScore': 30.0
    };
  } else {
    return {
      'survey_title': '불안 민감도 검사',
      'survey_content': '이 테스트는 기타 심리적 상태를 측정합니다.',
      'survey_score_intro': 
          '\n\n  0~15점 : 불안 자극에 민감하지 않습니다.'
          '\n16~20점 : 불안 자극에 약간 민감하게 반응합니다.'
          '\n21~24점 : 불안 자극에 상당히 민감하게 반응합니다.'
          '\n25~64점 : 불안 자극에 매우 민감하게 반응합니다.',
      'scorePositions': [0, 15, 20, 24, 64],
      'sectionWidths': [0.2325, 0.08, 0.0625, 0.625],
      'sectionColors': [
        color1, color2, color3, color5
      ],
      'maxScore': 64.0
    };
  }
}

void showResultDialog(BuildContext context, String surveyType, 
double totalScore, String resultDescription, String docid, [Function(String)? showConfirmDialog]) {
  final psyTestContain = get_psyTestInfo(surveyType);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          psyTestContain['survey_title'],
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: buildResultPage(context, psyTestContain, totalScore, resultDescription, docid, showConfirmDialog),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: primaryColor,
      );
    },
  );
}

Widget buildResultPage(BuildContext context, dynamic psyTestContain, double totalScore, String resultDescription, String docid, [Function(String)? showConfirmDialog] ) {
  final List<int> scorePositions = List<int>.from(psyTestContain['scorePositions']);
  final List<double> sectionWidths = List<double>.from(psyTestContain['sectionWidths']);
  final List<Color> sectionColors = List<Color>.from(psyTestContain['sectionColors']);
  final double maxScore = psyTestContain['maxScore'];
  final int checkScore;


  void navigateToNextPage() {
    if (maxScore == 100.0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AngerTestResults()),
      );
    } else if (maxScore == 30.0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StressTestResults()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnxietyTestResults()),
      );
    }
  }

  if(maxScore == 100.0){
    checkScore = 55;
  }else if(maxScore == 64.0){
    checkScore = 21;
  }else {
    checkScore = 17;
  }

return Center(
  child: SizedBox(
    width: 400,
    height: MediaQuery.of(context).size.height * 0.6,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end, // 텍스트를 이미지의 하단에 맞춤
          children: [
            Image.network(
              totalScore <= checkScore ? ImageUrls.normalRabbit : ImageUrls.sadRabbit,
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0), // 텍스트 위치 조정을 위해 패딩 추가
              child: Text(
                '당신의 점수는 $totalScore점 입니다.',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(resultDescription, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        CustomPaint(
          size: const Size(300, 50),
          painter: ResultPagePainter(totalScore, sectionWidths, scorePositions, sectionColors, maxScore),
        ),
        const SizedBox(height: 10),
        Text(
          psyTestContain['survey_score_intro'],
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showConfirmDialog == null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    navigateToNextPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                  ),
                  child: const Text('돌아가기'),
                ),
              if (showConfirmDialog != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                  ),
                  child: const Text('확인'),
                ),
              const SizedBox(width: 8),
              if (showConfirmDialog != null) // showConfirmDialog가 null이 아닐 때만 버튼을 보여줌
                ElevatedButton(
                  onPressed: () {
                    showConfirmDialog(docid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                  ),
                  child: const Text('삭제'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  ),
);


}

class ResultPagePainter extends CustomPainter {
  final double totalScore;
  final List<double> sectionWidths;
  final List<int> scorePositions;
  final List<Color> sectionColors;
  final double maxScore;

  ResultPagePainter(
    this.totalScore,
    this.sectionWidths,
    this.scorePositions,
    this.sectionColors,
    this.maxScore
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    canvas.drawRRect(rrect, paint);

    double startX = 0;
    for (int i = 0; i < sectionColors.length; i++) {
      final sectionPaint = Paint()..color = sectionColors[i];
      final sectionWidth = size.width * sectionWidths[i];
      final sectionRect = Rect.fromLTWH(startX, 0, sectionWidth, size.height);

      final sectionRRect = RRect.fromRectAndCorners(
        sectionRect,
        topLeft: i == 0 ? const Radius.circular(12) : Radius.zero,
        bottomLeft: i == 0 ? const Radius.circular(12) : Radius.zero,
        topRight: i == sectionColors.length - 1 ? const Radius.circular(12) : Radius.zero,
        bottomRight: i == sectionColors.length - 1 ? const Radius.circular(12) : Radius.zero,
      );

      canvas.drawRRect(sectionRRect, sectionPaint);
      startX += sectionWidth;
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int score in scorePositions) {
      final offsetX = size.width * (score / maxScore);

      final textSpan = TextSpan(
        text: '$score',
        style: const TextStyle(color: Colors.black),
      );

      textPainter.text = textSpan;
      textPainter.layout();

      textPainter.paint(canvas, Offset(offsetX - textPainter.width / 2, size.height + 5));

      final tickPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(offsetX, size.height),
        Offset(offsetX, size.height + 6),
        tickPaint,
      );
    }

    // 내 점수 표시하기
    final scoreX = size.width * (totalScore / maxScore);
    final scorePainter = TextPainter(
      text: const TextSpan(
        text: '',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );

    scorePainter.layout();
    scorePainter.paint(canvas, Offset(scoreX - scorePainter.width / 2, size.height / 2 - scorePainter.height / 2));

    final scoreLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(scoreX, size.height / 2 - scorePainter.height / 2 - 15),
      Offset(scoreX, size.height),
      scoreLinePaint,
    );

    final scoreTextPainter = TextPainter(
      text: TextSpan(
        text: '$totalScore',
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );

    scoreTextPainter.layout();
    scoreTextPainter.paint(canvas, Offset(scoreX - scoreTextPainter.width / 2, size.height / 2 - scorePainter.height / 2 - 35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
