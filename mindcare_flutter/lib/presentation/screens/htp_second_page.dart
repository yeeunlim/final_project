import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
// import '../widgets/custom_drawer.dart';
// import 'main.dart'; // main.dart 파일을 임포트합니다.
// import 'htp_drawing_page.dart'; // htp_drawing_page.dart 파일을 임포트합니다.
import 'htp_main_page.dart';

class HTPSecondPage extends StatelessWidget {
  final String token;

  HTPSecondPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: HTPCustomDrawer(token: token),
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
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_house.jpg'),
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_person.jpg'),
                        DrawingCard(imagePath: 'assets/htpTest/htp_main_tree.jpg'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/normal_rabbit.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 400, // 박스의 크기 설정
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
                  ],
                ),
                SizedBox(height: 40), // 버튼 간의 간격을 조정
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('이전 페이지'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) => HTPDrawingPage(token: token)),
                          MaterialPageRoute(builder: (context) => HTPMainPage(token: token)),
                        );
                      },
                      child: Text('시작하기'),
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

class HTPCustomDrawer extends StatelessWidget {
  final String token;

  HTPCustomDrawer({required this.token});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xff110f12),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            DrawerItem(icon: Icons.home, text: 'Home', onTap: () {}),
            DrawerItem(icon: Icons.person, text: 'Profile', onTap: () {}),
            DrawerItem(icon: Icons.settings, text: 'Settings', onTap: () {}),
          ],
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
      margin: EdgeInsets.all(8.0), // 여백을 추가하여 옆으로 키움
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
               
