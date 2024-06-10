import 'package:flutter/material.dart';
import 'pages/auth_helpers.dart';
import 'pages/login.dart';
// import 'pages/register.dart';
import 'pages/chat_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await AuthHelpers.checkLoginStatus();
    print(loggedIn);
    setState(() {
      isAuthenticated = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isAuthenticated ? const ChatScreen() : const LoginScreen(),
    );
  }
}
