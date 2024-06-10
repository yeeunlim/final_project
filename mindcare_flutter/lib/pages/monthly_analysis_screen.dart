import 'package:flutter/material.dart';
import '../widgets/mood_tracker.dart';

class MonthlyAnalysis extends StatelessWidget {
  final Map<DateTime, String> moodData;

  const MonthlyAnalysis({Key? key, required this.moodData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analysis'),
      ),
      body: MoodTracker(moodData: moodData),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MonthlyAnalysis(
      moodData: {
        DateTime.utc(2023, 6, 4): '기쁜 마음',
        DateTime.utc(2023, 6, 7): '기쁜 마음',
        DateTime.utc(2023, 6, 10): '불편한 마음',
        DateTime.utc(2023, 6, 11): '슬픈 마음',
      },
    ),
  ));
}
