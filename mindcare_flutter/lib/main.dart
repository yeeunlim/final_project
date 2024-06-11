import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/daily_analysis_screen.dart';
import 'pages/monthly_analysis_screen.dart';
import 'pages/main_screen.dart';
import 'pages/auth_helpers.dart';
import 'pages/login.dart';
// import 'pages/register.dart';


void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: '/main',
      home: const AuthChecker(), // 초기 위젯을 AuthChecker로 설정
      routes: {
        '/main': (context) => const MainScreen(),
        '/monthly_analysis': (context) => const MonthlyAnalysisScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/daily_analysis') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DailyAnalysisScreen(
                entryDate: args['entryDate'],
                entryData: args['entryData'],
                diaryText: args['diaryText'],
              );
            },
          );
        }
        return null;
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await AuthHelpers.checkLoginStatus();
    print(loggedIn);
    setState(() {
      isAuthenticated = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isAuthenticated ? const MainScreen() : const LoginScreen(),
    );
  }
}