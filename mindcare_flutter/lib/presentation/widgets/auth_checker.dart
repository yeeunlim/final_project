import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';

class AuthChecker extends StatefulWidget {
  final Widget child;
  const AuthChecker({super.key, required this.child});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool isAuthenticated = false;
  bool isLoading = true; // 초기 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      bool loggedIn = await AuthHelpers.checkLoginStatus();
      print('Login status checked: $loggedIn');
      setState(() {
        isAuthenticated = loggedIn;
        isLoading = false; // 로딩 완료로 설정
      });

      if (!loggedIn) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print('Error in _checkLoginStatus: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 로딩 중일 때 로딩 스피너 표시
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return isAuthenticated ? widget.child : const LoginScreen();
  }
}