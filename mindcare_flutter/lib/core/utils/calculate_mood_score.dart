import '../constants/emotion_scores.dart';

Map<String, double> calculateDailyMoodScores(List<dynamic> monthlyData) {
  final dailyScores = <String, double>{};

  for (var entry in monthlyData) {
    final date = entry['entry_date'];
    final emotionDistribution =
    Map<String, dynamic>.from(entry['emotion_distribution']);

    double dailyScore = 0.0;
    double totalWeight = 0.0;

    emotionDistribution.forEach((emotion, weight) {
      final score = emotionScores[emotion] ?? 0.0;
      dailyScore += score * (weight as double);
      totalWeight += weight;
    });

    if (totalWeight > 0) {
      dailyScore /= totalWeight;
    }

    dailyScores[date] = dailyScore;
  }

  return dailyScores;
}

int calculateAverageMoodScore(List<dynamic> monthlyData) {
  double totalScore = 0.0;
  int entryCount = 0;

  for (var entry in monthlyData) {
    final emotionDistribution =
    Map<String, dynamic>.from(entry['emotion_distribution']);

    double dailyScore = 0.0;
    double totalWeight = 0.0;

    emotionDistribution.forEach((emotion, weight) {
      final score = emotionScores[emotion] ?? 0.0;
      dailyScore += score * (weight as double);
      totalWeight += weight;
    });

    if (totalWeight > 0) {
      dailyScore /= totalWeight;
    }

    totalScore += dailyScore;
    entryCount++;
  }

  if (entryCount == 0) return 0;

  double averageScore = totalScore / entryCount;
  return averageScore.round();
}

// monthlyData에서 키워드의 기분 점수를 계산하는 함수
Map<String, double> calculateKeywordMoodScores(List<dynamic> monthlyData) {
  final keywordScores = <String, double>{};
  final keywordCounts = <String, double>{};

  // most_thought_background별로 데이터를 그룹화합니다.
  final backgroundGroups = <String, List<Map<String, dynamic>>>{};

  for (var entry in monthlyData) {
    final background = entry['most_thought_background'] as String;
    final emotionDistribution = Map<String, dynamic>.from(entry['emotion_distribution']);

    if (!backgroundGroups.containsKey(background)) {
      backgroundGroups[background] = [];
    }

    backgroundGroups[background]!.add(emotionDistribution);
  }

  // 각 그룹별로 감정 점수를 계산합니다.
  backgroundGroups.forEach((background, distributions) {
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (var distribution in distributions) {
      distribution.forEach((emotion, weight) {
        final score = emotionScores[emotion] ?? 0.0;
        totalScore += score * (weight as double);
        totalWeight += weight;
      });
    }

    if (totalWeight > 0) {
      keywordScores[background] = totalScore / totalWeight;
    } else {
      keywordScores[background] = 0.0;
    }
  });

  print('Final keywordMoodScores: $keywordScores');
  return keywordScores;
}
