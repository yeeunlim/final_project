import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/image_urls.dart';
import 'package:mindcare_flutter/core/services/auth_service.dart';
import 'package:mindcare_flutter/routes/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  // final String _token = '';

  // 초기 상태를 위해 사용자 정보를 로드하는 함수 (여기서는 예시로 기본 값을 사용)
  @override
  void initState() {
    super.initState();
    // 초기 사용자 정보를 로드합니다.
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await AuthHelpers.fetchUserInfo();
      setState(() {
        _emailController.text = userInfo['email'];
        _nameController.text = userInfo['name'];
        _nicknameController.text = userInfo['nickname'];
        _birthdateController.text = userInfo['birthdate'];
      });
    } catch (e) {
      // 오류 처리
      print('Failed to load user info: $e');
    }
  }

  Future<void> _deleteUser() async {
    try {
      await AuthHelpers.deleteUser();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login); // 'AppRoutes.login'을 사용하여 네비게이션
    } catch (e) {
      // 오류 처리
      print('Failed to delete user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 탈퇴에 실패했습니다.')),
      );
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      String? currentPassword = _currentPasswordController.text.isNotEmpty ? _currentPasswordController.text : null;
      String? newPassword = _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null;

      await AuthHelpers.updateUserInfo(
        context,
        _emailController.text,
        _nameController.text,
        _nicknameController.text,
        _birthdateController.text,
        currentPassword,
        newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보가 성공적으로 업데이트되었습니다.')),
      );
    } catch (e) {
      // 오류 처리
      print('Failed to update user info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보 업데이트에 실패했습니다.')),
      );

      // 오류 메시지를 다이얼로그로 표시
      AuthHelpers.showErrorDialog(context, e.toString());
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return ConfirmDialog(
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            _deleteUser(); // 탈퇴진행
          },
          onCancel: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          message: '정말로 탈퇴하시겠습니까?', // 메시지 전달
          confirmButtonText: '탈퇴하기', // 확인 버튼 텍스트
          cancelButtonText: '취소', // 취소 버튼 텍스트
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // 공통 AppBar 사용
      drawer: const CustomDrawer(), // 공통 Drawer 사용
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ImageUrls.loginPageBackground),
                fit: BoxFit.cover,
              ),
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
                children: [
                  const Text(
                    '내 정보 수정',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('이메일', _emailController),
                  const SizedBox(height: 20),
                  _buildTextField('이름', _nameController),
                  const SizedBox(height: 20),
                  _buildTextField('닉네임', _nicknameController),
                  const SizedBox(height: 20),
                  _buildTextField('생년월일', _birthdateController),
                  const SizedBox(height: 20),
                  _buildTextField('현재 비밀번호', _currentPasswordController, obscureText: true),
                  const SizedBox(height: 20),
                  _buildTextField('새 비밀번호', _newPasswordController, obscureText: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserInfo,
                    // _updateUserInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 158, 138, 229),
                    ),
                    child: const Text('수정하기'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showConfirmDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text('회원 탈퇴'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

