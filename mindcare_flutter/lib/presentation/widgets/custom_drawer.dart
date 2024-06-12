import 'package:flutter/material.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test1_home.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test3_home.dart';
import 'package:mindcare_flutter/presentation/screens/htp_main_page.dart'; // Import HTPMainPage

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
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: primaryColor,
                radius: 11,
              ),
              title: const Text(
                '심리 검사',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onTap: () {
                Navigator.pop(context);
              },
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
                          SnackBar(content: Text('Token is missing!')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('불안 민감도 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        // MaterialPageRoute(builder: (context) => const psyServey1()),  // Survey1 페이지로 이동합니다
                        MaterialPageRoute(builder: (context) => const AnxietyTestResults()),  // 불안 민감도 검사 홈 페이지로 이동합니다
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('스트레스 자각 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StressTestResults()),  // 
                      );                      
                    },
                  ),
                  ListTile(
                    title: const Text('노바코 분노 검사', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AngerTestResults()),  // 노바코 분노 검사 페이지로 이동합니다
                      );                      
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: primaryColor,
                radius: 11,
              ),
              title: const Text(
                '나의 감정 분석',
                style: TextStyle(color: Colors.white, fontSize: 20),
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

