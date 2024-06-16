import '../constants/emotion_categories.dart';

// 대분류
Map<String, int> calculateMajorCategoryCounts(List<dynamic> monthlyData) {
  final counts = {'긍정': 0, '중립': 0, '부정': 0};
  for (var entry in monthlyData) {
    final emotion = entry['most_felt_emotion'];
    final majorCategory = emotionMajorCategory[emotion] ?? '중립';
    if (counts.containsKey(majorCategory)) {
      counts[majorCategory] = counts[majorCategory]! + 1;
    }
  }
  return counts;
}

// 소분류
Map<String, int> calculateEmotionCounts(List<dynamic> monthlyData) {
  final counts = <String, int>{};
  for (var entry in monthlyData) {
    final emotion = entry['most_felt_emotion'];
    if (counts.containsKey(emotion)) {
      counts[emotion] = counts[emotion]! + 1;
    } else {
      counts[emotion] = 1;
    }
  }
  return counts;
}

Map<String, double> calculateSubCategoryRatios(List<dynamic> monthlyData) {
  // SubCategory 목록
  final subCategories = [
    '기쁜 마음',
    '평온한 마음',
    '놀란 마음',
    '불안한 마음',
    '불편한 마음',
    '힘든 마음',
    '싫은 마음',
    '슬픈 마음'
  ];

  // 각 SubCategory의 개수를 저장할 딕셔너리 초기화
  final counts = {for (var subCategory in subCategories) subCategory: 0};

  // 전체 감정 개수 초기화
  int totalEmotions = 0;

  // monthlyData를 순회하며 SubCategory 개수 카운트
  for (var entry in monthlyData) {
    final emotion = entry['most_felt_emotion'];
    final subCategory = emotionSubCategory[emotion] ?? '기타'; // 없는 경우 '기타'로 처리
    if (counts.containsKey(subCategory)) {
      counts[subCategory] = counts[subCategory]! + 1;
      totalEmotions++;
    }
  }

  // 비율 계산
  final ratios = {for (var subCategory in subCategories) subCategory: 0.0};
  for (var subCategory in subCategories) {
    if (totalEmotions > 0) {
      ratios[subCategory] = (counts[subCategory]! / totalEmotions) * 100;
    }
  }
  return ratios;
}