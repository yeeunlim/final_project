import 'package:flutter/material.dart';
import '../constants.dart'; // primaryColor를 가져오기 위해 추가

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // 메뉴바 배경색을 검정색으로 설정
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor, // 원의 색상 설정
                radius: 11, // 원의 반지름 설정
              ),
              title: Text(
                '심리 검사',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0), // 들여쓰기 설정
              child: Column(
                children: [
                  ListTile(
                    title: Text('HTP', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('불안 민감도 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('스트레스 자각 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('노바코 분노 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor, // 원의 색상 설정
                radius: 11, // 원의 반지름 설정
              ),
              title: Text(
                '나의 감정 분석',
                style: TextStyle(color: Colors.white, fontSize: 20), // 폰트 크기 키우기
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
