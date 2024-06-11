import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/themes/color_schemes.dart';

class ConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;

  const ConfirmDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.message,
    required this.confirmButtonText,
    required this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          width: 300,
          height: 200,
          decoration: const BoxDecoration(
            color: primaryColor,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter, // 컨테이너 하단에 정렬
                  child: Text(
                    message, // 전달된 메시지를 사용
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: onConfirm, // 전달된 버튼 텍스트 사용
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.white), // 흰색 테두리 추가
                        ),
                        child: Text(confirmButtonText),
                      ),
                      ElevatedButton(
                        onPressed: onCancel, // 전달된 버튼 텍스트 사용
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.white), // 흰색 테두리 추가
                        ),
                        child: Text(cancelButtonText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
