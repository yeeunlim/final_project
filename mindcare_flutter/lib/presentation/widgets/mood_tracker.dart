import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mindcare_flutter/core/constants/colors.dart'; // 감정 색상을 정의한 모듈
import 'package:intl/date_symbol_data_local.dart'; // 달력 언어 설정을 위해 추가
import 'package:mindcare_flutter/core/constants/emotion_categories.dart';

class MoodTracker extends StatelessWidget {
  final Map<DateTime, String> moodData;
  final void Function(DateTime, bool) onDateSelected;

  const MoodTracker({super.key, required this.moodData, required this.onDateSelected});

  // 감정 카테고리에 따라 색상을 반환하는 함수
  Color getMoodColor(String emotion) {
    final category = emotionSubCategory[emotion];
    return emotionColors[category] ?? Colors.grey;
  }

  // 날짜 비교 함수 (시간 부분을 무시)
  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(); // 날짜 형식 초기화

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        locale: 'ko_KR', // 달력 언어를 한국어로 설정
        firstDay: DateTime.utc(2020, 1, 1), // 달력의 시작 날짜
        lastDay: DateTime.utc(2030, 12, 31), // 달력의 마지막 날짜
        focusedDay: DateTime.now(), // 현재 날짜에 포커스
        calendarFormat: CalendarFormat.month, // 기본 형식을 월간 형식으로 설정
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month', // 월간 형식만 사용
        },
        daysOfWeekHeight: 40.0, // 요일 텍스트와 날짜들 사이의 간격 조정
        selectedDayPredicate: (day) {
          // 선택된 날짜를 기준으로 색상을 설정
          return moodData.keys.any((d) => isSameDay(d, day));
        },
        onDaySelected: (selectedDay, focusedDay) {
          final hasDiary = moodData.keys.any((d) => isSameDay(d, selectedDay)); // 선택된 날짜에 감정 데이터가 있는지 확인
          print('onDaySelected: selectedDay: $selectedDay, hasDiary: $hasDiary'); // 디버깅 정보 출력
          onDateSelected(selectedDay, hasDiary); // 날짜 선택 콜백 호출
        },
        headerStyle: HeaderStyle(
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22.0), // 월과 년도를 표시한 텍스트를 흰색으로 설정
          formatButtonVisible: false, // 형식 버튼 숨김
          titleCentered: true, // 제목을 중앙 정렬
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: Colors.white, // 왼쪽 화살표 아이콘 색상
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: Colors.white, // 오른쪽 화살표 아이콘 색상
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: lightGray, fontSize: 18.0, fontWeight: FontWeight.bold), // 요일 텍스트를 회색으로 설정하고 크기 조정
          weekendStyle: TextStyle(color: lightGray, fontSize: 18.0, fontWeight: FontWeight.bold), // 주말 텍스트를 회색으로 설정하고 크기 조정
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final isPastDate = day.isBefore(DateTime.now()); // 현재 날짜 이전의 날짜인지 확인
            final textColor = isPastDate ? lightGray : Colors.white;
            final defaultDecoration = BoxDecoration(
              shape: BoxShape.circle, // 원형으로 표시
            );

            // 선택된 날짜가 moodData에 있는 경우
            if (moodData.keys.any((d) => isSameDay(d, day))) {
              final emotion = moodData.entries.firstWhere((entry) => isSameDay(entry.key, day)).value;
              final color = getMoodColor(emotion);
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration.copyWith(
                  color: color,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              );
            } else {
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: textColor, fontSize: 18.0), // 현재 날짜 이전이면 회색 텍스트, 그렇지 않으면 검은색 텍스트, 크기 조정
                  ),
                ),
              );
            }
          },
          selectedBuilder: (context, day, focusedDay) {
            final isPastDate = day.isBefore(DateTime.now());
            final textColor = isPastDate ? lightGray : Colors.white;
            final defaultDecoration = BoxDecoration(
              shape: BoxShape.circle,
            );

            if (moodData.keys.any((d) => isSameDay(d, day))) {
              final emotion = moodData.entries.firstWhere((entry) => isSameDay(entry.key, day)).value;
              final color = getMoodColor(emotion);
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration.copyWith(
                  color: color,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              );
            } else {
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18.0),
                  ),
                ),
              );
            }
          },
          todayBuilder: (context, day, focusedDay) {
            final isPastDate = day.isBefore(DateTime.now());
            final textColor = isPastDate ? lightGray : Colors.white;
            final defaultDecoration = BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
            );

            if (moodData.keys.any((d) => isSameDay(d, day))) {
              final emotion = moodData.entries.firstWhere((entry) => isSameDay(entry.key, day)).value;
              final color = getMoodColor(emotion);
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration.copyWith(
                  color: color,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              );
            } else {
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: defaultDecoration,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
