import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:mindcare_flutter/presentation/widgets/auth_checker.dart';
import 'package:mindcare_flutter/routes/app_routes.dart';
import 'package:mindcare_flutter/presentation/screens/htp_drawing_page.dart'; // DrawingProvider 경로에 맞게 임포트

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingProvider()), // DrawingProvider 추가
        // 다른 Providers를 추가할 수 있습니다.
      ],
      child: MaterialApp(
        home: const AuthChecker(),
        routes: getAppRoutes(), // 정적 라우트 설정을 getAppRoutes() 함수로 대체합니다.
        onGenerateRoute: generateRoute, // 동적 라우트 설정을 generateRoute 함수로 대체합니다.
      ),
    );
  }
}
