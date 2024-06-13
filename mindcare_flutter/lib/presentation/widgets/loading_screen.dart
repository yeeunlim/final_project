import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:mindcare_flutter/core/constants/loading_texts.dart';
import 'package:mindcare_flutter/core/constants/colors.dart';

import '../../core/constants/urls.dart';

class LoadingScreen extends StatefulWidget {
  final bool isLoading;
  final String upperText;

  const LoadingScreen({
    super.key,
    required this.isLoading,
    required this.upperText,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Timer _timer;
  late String _currentLowerText;

  @override
  void initState() {
    super.initState();
    _currentLowerText = loadingTexts[0];
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentLowerText = loadingTexts[Random().nextInt(loadingTexts.length)];
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 300, // 고정 너비
          height: 400, // 고정 높이
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.upperText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 20),
              Image.network(
                ImageUrls.loadingImage,
                width: 200, // 고정 너비
                height: 200, // 고정 높이
              ),
              SizedBox(
                width: double.infinity,
                height: 50, // 고정 높이
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _currentLowerText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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

