import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CustomAppBar({Key? key, this.title}) : super(key: key);

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
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            // 홈 버튼 클릭 이벤트 처리
          },
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            // 마이페이지 버튼 클릭 이벤트 처리
          },
        ),
        IconButton(
          icon: const Icon(Icons.login, color: Colors.white),
          onPressed: () {
            // 로그인/로그아웃 버튼 클릭 이벤트 처리
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
