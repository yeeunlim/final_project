import 'package:flutter/material.dart';
import 'dart:math';

class EmotionCircles extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionCircles({Key? key, required this.emotionCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCount = emotionCounts.values.reduce(max);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: emotionCounts.entries.map((entry) {
        final proportion = entry.value / maxCount;
        final radius = 50 + (proportion * 50);
        return Container(
          width: radius,
          height: radius,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              entry.key,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
