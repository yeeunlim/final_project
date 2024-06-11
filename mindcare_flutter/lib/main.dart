import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/app_routes.dart';
import 'core/services/auth_service.dart';
import 'presentation/widgets/auth_checker.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthChecker(), // 초기 위젯을 AuthChecker로 설정
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
