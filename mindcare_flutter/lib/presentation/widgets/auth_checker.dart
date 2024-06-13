import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/presentation/screens/chatbot_diary_entry_screen.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';

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
    // print(loggedIn);
    setState(() {
      isAuthenticated = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isAuthenticated ? const ChatbotDiaryEntryScreen() : const LoginScreen(),
    );
  }
}
