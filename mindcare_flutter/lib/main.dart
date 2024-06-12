import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // provider 패키지 추가
import 'routes/app_routes.dart';
import 'presentation/widgets/auth_checker.dart';
import 'presentation/screens/htp_drawing_page.dart'; // htp_drawing_page 추가

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
      ],
      child: MaterialApp(
        home: const AuthChecker(), // 초기 위젯을 AuthChecker로 설정
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
