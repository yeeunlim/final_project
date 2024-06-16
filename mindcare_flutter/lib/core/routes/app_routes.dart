import 'package:flutter/material.dart';
import 'package:mindcare_flutter/presentation/screens/daily_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import 'package:mindcare_flutter/presentation/screens/chatbot_diary_entry_screen.dart';
import 'package:mindcare_flutter/presentation/screens/monthly_analysis_screen.dart';
import 'package:mindcare_flutter/presentation/screens/mypage.dart';
import 'package:mindcare_flutter/presentation/screens/register.dart';

// 라우트 경로를 상수로 정의한 클래스
class AppRoutes {
  static const String chatbotDiary = '/chatbot_diary';
  static const String monthlyAnalysis = '/monthly_analysis';
  static const String mypage = '/mypage';
  static const String login = '/login';
  static const String dailyAnalysis = '/daily_analysis';
  static const String register = '/register';
}

// 라우팅 테이블을 정의합니다.
Map<String, WidgetBuilder> getAppRoutes() {
  return {
    AppRoutes.chatbotDiary: (context) => const ChatbotDiaryEntryScreen(),
    AppRoutes.monthlyAnalysis: (context) => const MonthlyAnalysisScreen(),
    AppRoutes.mypage: (context) => const MyPage(),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.register: (context) => const SignUpScreen(),
  };
}

// 동적 라우팅을 처리하는 함수를 정의합니다.
Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.dailyAnalysis:
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
    case AppRoutes.chatbotDiary:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (context) {
          return ChatbotDiaryEntryScreen(
            selectedDate: args?['selectedDate'],
          );
        },
      );
    default:
      return null;
  }
}