// monthlyData에서 키워드의 개수를 계산하는 함수
Map<String, int> calculateBackgroundCounts(List<dynamic> monthlyData) {
  final counts = <String, int>{};
  for (var entry in monthlyData) {
    final background = entry['most_thought_background'];
    if (counts.containsKey(background)) {
      counts[background] = counts[background]! + 1;
    } else {
      counts[background] = 1;
    }
  }
  return counts;
}