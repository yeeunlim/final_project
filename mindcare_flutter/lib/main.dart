import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'auth_helpers.dart';
import 'login.dart';
// import 'main_old.dart';
import 'register.dart';
import 'diary.dart';
import 'pages/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const AuthChecker(),
//         '/login': (context) => const LoginScreen(),
//         '/register': (context) => const SignUpScreen(),
//         '/main': (context) => const MainPage(),  // MainPage로 변경
//       },
//     );
//   }
// }

// class AuthChecker extends StatefulWidget {
//   const AuthChecker({super.key});

//   @override
//   _AuthCheckerState createState() => _AuthCheckerState();
// }

// class _AuthCheckerState extends State<AuthChecker> {
//   bool isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await AuthHelpers.checkLoginStatus();
//     print(loggedIn);
//     setState(() {
//       isAuthenticated = loggedIn;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isAuthenticated ? const MainPage() : const LoginScreen(),  // MainPage로 변경
//     );
//   }
// }

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   bool isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await AuthHelpers.checkLoginStatus();
//     print(loggedIn);
//     setState(() {
//       isAuthenticated = loggedIn;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff110f12),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: isAuthenticated
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.logout),
//                   onPressed: () async {
//                     await AuthHelpers.logout(context);
//                     setState(() {
//                       isAuthenticated = false;
//                     });
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
//                   },
//                 ),
//               ]
//             : null,
//       ),
//       drawer: _buildDrawer(context),  // drawer 설정 추가
//       body: const DiaryPage(),
//     );
//   }

//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: Container(
//         color: const Color(0xff110f12),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home, color: Colors.white),
//               title: const Text('Home', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MainPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person, color: Colors.white),
//               title: const Text('Profile', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // 프로필 메뉴 클릭 시 수행할 작업
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings, color: Colors.white),
//               title: const Text('Settings', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 // 설정 메뉴 클릭 시 수행할 작업
//               },
//             ),
//           ],
//         ),
//       ),

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),

    );
  }
}
