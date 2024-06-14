import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class AlertDialogHelper {
  static void showAlert(
      BuildContext context, String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면의 다른 부분을 클릭해도 닫히지 않음
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: primaryColor,
          child: Container(
            width: 300,
            height: 200,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 16.0),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  // textAlign: TextAlign.start,
                ),
                const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white), // 흰색 테두리 추가
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                            if (onConfirm != null) {
                              onConfirm(); // 확인 버튼을 누른 후 콜백 함수 실행
                            }
                          },
                          child: const Text('확인', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 25.0),
                      ],
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }
}
