import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mindcare_flutter/core/services/drawing_provider.dart';
import 'package:mindcare_flutter/presentation/widgets/auth_checker.dart';
import 'package:mindcare_flutter/providers/monthly_analysis_provider.dart';
import 'package:mindcare_flutter/routes/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyAnalysisModel()),
      ],
      child: MaterialApp(
        home: const AuthChecker(),
        routes: getAppRoutes(), // 정적 라우트 설정을 getAppRoutes() 함수로 대체합니다.
        onGenerateRoute: generateRoute, // 동적 라우트 설정을 generateRoute 함수로 대체합니다.
      ),
    );
  }
}
