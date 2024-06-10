import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/daily_analysis_screen.dart';
import 'pages/monthly_analysis_screen.dart';
import 'pages/main_screen.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/main',
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
