import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/auth_checker.dart';
// import 'main.dart'; // main.dart 파일을 임포트합니다.
import 'htp_second_page.dart'; // 새로운 페이지 파일을 임포트합니다.


class HTPMainPage extends StatelessWidget {
  final String token;

  HTPMainPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(token: token),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측 상단에 "HTP 검사" 타이틀 추가
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
                // "HTP 검사란?" 박스
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'HTP 검사란?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // 설명 박스
                Row(
                  children: [
                    Image.asset(
                      'assets/normal_rabbit.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '벅(Buck, 1948)이 고안한 투사적 그림검사로서 집, 나무, 사람을 각각 그리게 하여 '
                              '내담자의 성격, 행동 양식 및 대인관계를 파악할 수 있습니다. 피험자의 성격적 특징뿐만 아니라 지적 수준을 평가하고 '
                              '또한 정신장애 및 신경증의 부분적 양상을 파악하는데 널리 사용되기도 합니다.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 대화창 스타일의 보라색 박스
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // 패딩 조정
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_house.jpg'),
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_person.jpg'),
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_tree.jpg'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40), // 버튼 간의 간격을 조정
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AuthChecker()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('메인 페이지'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HTPSecondPage(token: token)), // 새로운 페이지로 이동
                        );
                      },
                      child: Text('다음'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  DrawerItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class DrawingCard extends StatelessWidget {
  final String imagePath;

  DrawingCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.0), // 여백을 추가하여 옆으로 키움
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Image.asset(
          imagePath,
          width: 150, // 이미지 크기 확장
          height: 150,
        ),
      ),
    );
  }
}

