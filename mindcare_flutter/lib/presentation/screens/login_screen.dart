import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/presentation/widgets/alert_dialog.dart';
import 'package:mindcare_flutter/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _showAlertDialog() {
    AlertDialogHelper.showAlert(
      context,
      '로그인',
      '로그인 실패:\n아이디/비밀번호를 확인해 주세요.',
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      bool success = await AuthHelpers.login(_username, _password, context);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('jwt_token');
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.chatbotDiary,
          arguments: token,
        );
      } else {
        _showAlertDialog();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('로그인 실패: 아이디/비밀번호를 확인해 주세요.')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ImageUrls.loginPageBackground), // 네트워크 이미지 경로 사용
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: 100, // 상단에서 100 픽셀 아래에 위치
            left: 20, // 왼쪽에서 20 픽셀 오른쪽에 위치
            right: 20, // 오른쪽에서 20 픹셀 왼쪽에 위치
            child: Column(
              children: [
                Text(
                  '나만의 감정 가이드',
                  style: TextStyle(
                    fontSize: 14, // 첫 번째 줄 글자 크기
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'MAMA - MIA',
                  style: TextStyle(
                    fontSize: 26, // 두 번째 줄 글자 크기
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '로그인',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(labelText: '아이디'),
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '아이디를 입력하세요';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: '비밀번호'),
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력하세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor,
                          ),
                          child: const Text(' 로그인 '),
                        ),
                        const SizedBox(height: 10),
                        const Text('-------------- 또는 --------------'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor,
                          ),
                          child: const Text('회원가입'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
