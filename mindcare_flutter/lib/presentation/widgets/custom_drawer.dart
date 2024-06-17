import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';
import 'package:mindcare_flutter/presentation/screens/htp_main_page.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test1_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test3_home.dart';
import 'package:mindcare_flutter/core/routes/app_routes.dart'; // 라우트 경로를 가져오기 위해 추가
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final String? token;

  const CustomDrawer({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
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
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 11,
                  ),
                  SizedBox(width: 16),
                  Text(
                    '나의 감정 분석',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('월별 감정 통계', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.monthlyAnalysis);  // 월별 감정 통계 페이지로 이동
                    },
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 11,
                  ),
                  SizedBox(width: 16),
                  Text(
                    '심리 검사',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('HTP', style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('jwt_token');
                      if (token != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HTPMainPage(token: token),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token is missing!')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('불안 민감도 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.psytest1);  // 심리검사 페이지로 이동
                    },                    
                  ),
                  ListTile(
                    title: const Text('스트레스 자각 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.psytest2);  // 심리검사 페이지로 이동
                    },   
                  ),
                  ListTile(
                    title: const Text('노바코 분노 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.psytest3);  // 심리검사 페이지로 이동
                    },   
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
