import 'package:flutter/material.dart';
import 'package:mindcare_flutter/presentation/screens/daily_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import 'package:mindcare_flutter/presentation/screens/chatbot_diary_entry_screen.dart';
import 'package:mindcare_flutter/presentation/screens/monthly_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/mypage.dart';
import 'package:mindcare_flutter/presentation/screens/register.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test1_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test2_home.dart';
import 'package:mindcare_flutter/presentation/screens/psy_test3_home.dart';
// import 'package:mindcare_flutter/presentation/screens/htp_main_page.dart';

import '../services/auth_checker.dart';

// 라우트 경로를 상수로 정의한 클래스
class AppRoutes {
  static const String chatbotDiary = '/chatbot_diary';
  static const String monthlyAnalysis = '/monthly_analysis';
  static const String mypage = '/mypage';
  static const String login = '/login';
  static const String dailyAnalysis = '/daily_analysis';
  static const String register = '/register';
  static const String psytest1 = '/anxiety_test';
  static const String psytest2 = '/stress_test';
  static const String psytest3 = '/anger_test';
  static const String htpmain = '/htp_test';
}

// 정적 라우팅
Map<String, WidgetBuilder> getAppRoutes() {
  return {
    AppRoutes.chatbotDiary: (context) => const AuthChecker(child: ChatbotDiaryEntryScreen()),
    AppRoutes.monthlyAnalysis: (context) => const AuthChecker(child: MonthlyAnalysisScreen()),
    AppRoutes.mypage: (context) => const AuthChecker(child: MyPage()),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.register: (context) => const SignUpScreen(),
    AppRoutes.psytest1: (context) => const AuthChecker(child: AnxietyTestResults()),
    AppRoutes.psytest2: (context) => const AuthChecker(child: StressTestResults()),
    AppRoutes.psytest3: (context) => const AuthChecker(child: AngerTestResults()),
    // AppRoutes.htpmain: (context) => const AuthChecker(child: HTPMainPage()),
  };
}

// 동적 라우팅
Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.dailyAnalysis:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) {
          return AuthChecker(
            child: DailyAnalysisScreen(
              entryDate: args['entryDate'],
              entryData: args['entryData'],
              diaryText: args['diaryText'],
            ),
          );
        },
      );
    case AppRoutes.chatbotDiary:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (context) {
          return AuthChecker(
            child: ChatbotDiaryEntryScreen(
              selectedDate: args?['selectedDate'],
            ),
          );
        },
      );
    default:
      return null;
  }
}
