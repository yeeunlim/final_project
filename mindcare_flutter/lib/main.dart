import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mindcare_flutter/core/services/drawing_provider.dart';
import 'package:mindcare_flutter/presentation/screens/chatbot_diary_entry_screen.dart';
import 'package:mindcare_flutter/core/services/auth_checker.dart';
import 'package:mindcare_flutter/core/services/monthly_analysis_provider.dart';
import 'package:mindcare_flutter/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'core/utils/custom_scroll_behavior.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DrawingProvider>(
          create: (context) => DrawingProvider(),
        ),
        ChangeNotifierProvider<MonthlyAnalysisModel>(
          create: (context) => MonthlyAnalysisModel(context),
        ),
      ],
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),  // 가로스크롤 커스텀
        child: MaterialApp(
          home: const AuthChecker(child: ChatbotDiaryEntryScreen()), // child 파라미터 추가
          routes: getAppRoutes(), // 정적 라우트 설정을 getAppRoutes() 함수로 대체합니다.
          onGenerateRoute: generateRoute, // 동적 라우트 설정을 generateRoute 함수로 대체합니다.
        ),
      ),
    );
  }
}
