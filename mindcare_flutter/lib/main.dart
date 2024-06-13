import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mindcare_flutter/routes/app_routes.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/chatbot_diary', // 초기 경로를 설정합니다.
      routes: getAppRoutes(), // 정적 라우트 설정을 getAppRoutes() 함수로 대체합니다.
      onGenerateRoute: generateRoute, // 동적 라우트 설정을 generateRoute 함수로 대체합니다.
    );
  }
}



// class AuthChecker extends StatefulWidget {
//   const AuthChecker({super.key});
//
//   @override
//   _AuthCheckerState createState() => _AuthCheckerState();
// }
//
// class _AuthCheckerState extends State<AuthChecker> {
//   bool isAuthenticated = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }
//
//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await AuthHelpers.checkLoginStatus();
//     print(loggedIn);
//     setState(() {
//       isAuthenticated = loggedIn;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isAuthenticated ? const MainScreen() : const LoginScreen(),
//     );
//   }
// }