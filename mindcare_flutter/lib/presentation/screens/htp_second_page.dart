import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/presentation/widgets/common_button.dart';
import 'htp_drawing_page.dart';

class HTPSecondPage extends StatelessWidget {
  final String token;

  HTPSecondPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(token: token),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(ImageUrls.mainPageBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'HTP 검사',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 600, // 각 박스 크기를 다르게 설정
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center( // 텍스트를 가운데로 정렬
                      child: Text(
                        '집(Home), 나무(Tree), 사람(Person)을 모두 그리지 않아도 됩니다.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20, // 폰트 크기를 키움
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // 텍스트 가운데 정렬
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: 550, // 각 박스 크기를 다르게 설정
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center( // 텍스트를 가운데로 정렬
                      child: Text(
                        '단순히 집, 나무, 사람 그림뿐만이 아니라 위치와 연관되는 모든 객체, 예를 들자면 연못, 길, 다추, 운동화, 울타리, 해, 별, 꽃, 다람쥐 등 '
                            '주의의 객체도 인식하여 심리검사를 진행합니다.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16, // 폰트 크기를 키움
                        ),
                        textAlign: TextAlign.center, // 텍스트 가운데 정렬
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 650, // 이미지 3개가 들어있는 박스와 동일한 너비 설정
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // 패딩 조정
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DrawingCard(imagePath: ImageUrls.htpMainHouse),
                          DrawingCard(imagePath: ImageUrls.htpMainTree),
                          DrawingCard(imagePath: ImageUrls.htpMainPerson),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        ImageUrls.normalRabbit,
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 16),
                      Flexible(
                        child: Container(
                          width: 550,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center( // 텍스트를 가운데로 정렬
                            child: Text(
                              '준비가 되었다면 ‘시작하기’를 눌러주세요',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20, // 폰트 크기를 키움
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // 텍스트 가운데 정렬
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40), // 버튼 간의 간격을 조정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonButton(
                        text: '이전 페이지',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CommonButton(
                        text: '시작하기',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HTPDrawingPage(token: token)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingCard extends StatelessWidget {
  final String imagePath;

  DrawingCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isScreenSmall = screenWidth < 200;

    return Flexible(
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isScreenSmall
              ? Container() // 화면이 작을 때는 이미지를 숨김
              : Image.network(
            imagePath,
            width: 300,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
