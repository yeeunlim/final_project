import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/core/routes/app_routes.dart';

import '../../core/services/diary_entry_service.dart'; // 라우트 경로를 가져오기 위해 추가

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CustomAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // AppBar 색상 설정
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: title != null ? Text(title!, style: const TextStyle(color: Colors.white)) : null,
      actions: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              final diaryEntryService = DiaryEntryService(context);
              final selectedDate = DateTime.now().toIso8601String().split('T')[0];
              final entries = await diaryEntryService.getDiaryEntries(entryDate: selectedDate);

              if (entries.isNotEmpty) {
                final diaryEntry = entries.firstWhere((entry) =>
                entry['entry_date'] == selectedDate);

                Navigator.pushNamed(
                  context,
                  '/daily_analysis',
                  arguments: {
                    'entryDate': diaryEntry['entry_date'],
                    'entryData': diaryEntry,
                    'diaryText': diaryEntry['diary_text'],
                  },
                );
              } else {
                Navigator.of(context).pushNamed(AppRoutes.chatbotDiary);
              }
            },
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.mypage); // 마이페이지 버튼 클릭 시 이동할 경로 설정
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: 5),
                  Text('마이페이지', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              AuthHelpers.logout(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Icon(Icons.login, color: Colors.white),
                  SizedBox(width: 5),
                  Text('로그아웃', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
