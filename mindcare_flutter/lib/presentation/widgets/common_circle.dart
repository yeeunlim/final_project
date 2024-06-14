import 'package:flutter/material.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

class CommonCircle extends StatelessWidget {
  final String circleText;

  const CommonCircle({required this.circleText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // 원의 너비
      height: 120, // 원의 높이
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          circleText,
          style: const TextStyle(
            color: deepPurple,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
