import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_flutter/core/constants/colors.dart';
import 'dart:convert';
import 'package:mindcare_flutter/presentation/screens/login_screen.dart';
import 'package:mindcare_flutter/presentation/widgets/alert_dialog.dart';
import 'package:mindcare_flutter/core/constants/urls.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: SignUpScreen(),
//     );
//   }
// }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthdateController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _nicknameFocusNode = FocusNode();
  final _birthdateFocusNode = FocusNode();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmError;
  String? _birthdateError;
  Color? _usernameErrorColor;

  bool _isUsernameAvailable = true;
  // final String _usernameCheckMessage = '';

  @override
  void initState() {
    super.initState();

    _usernameFocusNode.addListener(_onUsernameFocusChange);

    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus) {
        setState(() {
          _usernameError = _validateUsername(_usernameController.text, false);
        });
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = _validateEmail(_emailController.text);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = _validatePassword(_passwordController.text);
        });
      }
    });

    _passwordConfirmFocusNode.addListener(() {
      if (!_passwordConfirmFocusNode.hasFocus) {
        setState(() {
          _passwordConfirmError = _validatePasswordConfirm(_passwordConfirmController.text);
        });
      }
    });

    _birthdateFocusNode.addListener(() {
      if (!_birthdateFocusNode.hasFocus) {
        setState(() {
          _birthdateError = _validateBirthdate(_birthdateController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _birthdateController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    _nameFocusNode.dispose();
    _nicknameFocusNode.dispose();
    _birthdateFocusNode.dispose();
    super.dispose();
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocusNode.hasFocus && _usernameError != null && !_isUsernameAvailable) {
      // 포커스가 다른 곳으로 이동하려고 할 때 에러가 있다면 다시 포커스를 설정
      FocusScope.of(context).requestFocus(_usernameFocusNode);
    }
  }

  void _showAlertDialog(String msg, bool move) {
    String errorMsg = '';
    if(!move){
      // 문자열을 ':'로 분할하여 리스트로 변환
      List<String> parts = msg.split(':');
      // 리스트의 마지막 요소를 가져옴
      errorMsg = parts.last;

      if(!msg.contains('<')) {
        if(errorMsg.contains('[') ){
          // 대괄호를 제거하는 정규식 패턴과 대체 함수 정의
          RegExp from = RegExp(r'\}|\"|\[|\]');

          // 각 메시지에 대해 대괄호 제거
          errorMsg = errorMsg.replaceAll(from, '');
          // print(errorMsg);
        }
      }
    }    

    AlertDialogHelper.showAlert(
      context,
      '회원가입',
      move ? msg: '회원가입 실패:\n$errorMsg',
      // '회원가입 실패:\n$msg',
      onConfirm: move ? () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } : null,
    );
  }


  Future<void> _signUp() async {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text, false);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _passwordConfirmError = _validatePasswordConfirm(_passwordConfirmController.text);
      _birthdateError = _validateBirthdate(_birthdateController.text);
    });

    if (_usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _passwordConfirmError == null &&
        _birthdateError == null) {
      final response = await http.post(
        Uri.parse('$userAuthUrl/custom/registration/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'password1': _passwordController.text,
          'password2': _passwordController.text,
          'name': _nameController.text,
          'nickname': _nicknameController.text,
          'birthdate': _birthdateController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        _showAlertDialog('회원가입 성공:\n로그인 해주세요.', true);
      } else {
        _showAlertDialog(response.body, false);
      }
    }
  }

  Future<void> _checkUsernameAvailability() async {    
    setState(() {
      _usernameError = _validateUsername(_usernameController.text, true);
    });

    if( _usernameError != null){
      return;
    }
    // print(userAuthUrl);

    final response = await http.post(
      Uri.parse('$userAuthUrl/custom/check_username/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': _usernameController.text}),
    );

    final responseData = json.decode(response.body);

    setState(() {
      _isUsernameAvailable = responseData['available'];
      _usernameError = _isUsernameAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.';
      _usernameErrorColor = _isUsernameAvailable?Colors.green.shade900 :  Colors.red.shade900 ;

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(ImageUrls.loginPageBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: InputDecoration(
                  labelText: '아이디 (중복체크 V)',
                  errorText: _usernameError,
                  errorStyle: TextStyle(color: _usernameErrorColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _checkUsernameAvailability,
                  ),
                ),
              ),
                          const SizedBox(height: 5),
                          // _buildErrorText(_usernameError),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '이메일',
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            errorText: _emailError,
                          ),
                          const SizedBox(height: 5),
                          // _buildErrorText(_emailError),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '비밀번호',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: true,
                            errorText: _passwordError,
                          ),
                          const SizedBox(height: 5),
                          // _buildErrorText(_passwordError),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '비밀번호 확인',
                            controller: _passwordConfirmController,
                            focusNode: _passwordConfirmFocusNode,
                            obscureText: true,
                            errorText: _passwordConfirmError,
                          ),
                          const SizedBox(height: 5),
                          // _buildErrorText(_passwordConfirmError),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '이름',
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                          ),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '닉네임',
                            controller: _nicknameController,
                            focusNode: _nicknameFocusNode,
                          ),
                          const SizedBox(height: 10),
                          _buildTextFormField(
                            label: '생년월일',
                            controller: _birthdateController,
                            focusNode: _birthdateFocusNode,
                            errorText: _birthdateError,
                          ),
                          const SizedBox(height: 5),
                          // _buildErrorText(_birthdateError),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: secondaryColor,
                            ),                            
                            child: const Text('회원가입'),
                          ),
                          const SizedBox(height: 10),
                          const Text('-------------- 또는 --------------'),
                          const SizedBox(height: 10),                                  
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor,
                          ),                            
                            child: const Text(' 로그인 '),
                          ),                     
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        errorText: errorText, 
        errorStyle: TextStyle(color: errorText != null ? Colors.red.shade900 : Colors.green.shade700), // 에러 메시지 색상 지정
        // errorText를 추가
      ),
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
    );
  }

  String? _validateUsername(String? value, bool newFlag) {
    if (!newFlag & (_usernameError == '이미 사용 중인 아이디입니다.')){
      return _usernameError;
    }
    if (value == null || value.isEmpty) {
      return '아이디를 입력해주세요';
    }
    if (value.length < 6) {
      return '아이디는 6자 이상이어야 합니다';
    }
    if (RegExp(r'^[0-9]').hasMatch(value)) {
      return '아이디는 숫자로 시작할 수 없습니다';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!value.contains('@')) {
      return '유효한 이메일 주소를 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return '비밀번호는 문자와 숫자를 모두 포함해야 합니다';
    }
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }
  
  String? _validateBirthdate(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 입력해주세요';
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return '생년월일은 8자리 숫자여야 합니다 (예: 20001206)';
    }
    return null;
  }
}
