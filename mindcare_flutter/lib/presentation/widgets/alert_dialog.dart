import 'package:flutter/material.dart';

class AlertDialogHelper {
  static void showAlert(
      BuildContext context, String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                if (onConfirm != null) {
                  onConfirm(); // 확인 버튼을 누른 후 콜백 함수 실행
                }
              },
            ),
          ],
        );
      },
    );
  }
}