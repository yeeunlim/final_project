import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';

class MoodTracker extends StatelessWidget {
  final Map<DateTime, String> moodData;
  final void Function(DateTime, bool) onDateSelected;

  const MoodTracker({super.key, required this.moodData, required this.onDateSelected});

  Color getMoodColor(String emotionCategory) {
    return emotionColors[emotionCategory] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month, // 기본 형식을 월간 형식으로 설정
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month', // 월간 형식만 사용
        },
        selectedDayPredicate: (day) {
          // 선택된 날짜를 기준으로 색상을 설정합니다.
          return moodData.containsKey(day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          final hasDiary = moodData.containsKey(selectedDay);
          onDateSelected(selectedDay, hasDiary);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (moodData.containsKey(day)) {
              final emotionCategory = moodData[day]!;
              final color = getMoodColor(emotionCategory);
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else {
              return Center(
                child: Text(
                  day.day.toString(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
