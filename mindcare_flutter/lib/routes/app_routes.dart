import 'package:flutter/material.dart';
import 'package:mindcare_flutter/presentation/screens/daily_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import 'package:mindcare_flutter/presentation/screens/main_screen.dart';
import 'package:mindcare_flutter/presentation/screens/monthly_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/mypage.dart';

class AppRoutes {
  static const String main = '/main';  // MainScreen의 경로
  static const String monthlyAnalysis = '/monthly_analysis';  // MonthlyAnalysisScreen의 경로
  static const String myPage = '/mypage';  // MyPage의 경로
  static const String login = '/login';  // LoginScreen의 경로
  static const String dailyAnalysis = '/daily_analysis';  // DailyAnalysisScreen의 경로

  // 라우트를 생성하는 함수
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case monthlyAnalysis:
        return MaterialPageRoute(builder: (_) => const MonthlyAnalysisScreen());
      case myPage:
        return MaterialPageRoute(builder: (_) => const MyPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dailyAnalysis:
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
