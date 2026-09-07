class WearableActivitySummary {
  final int todaySteps;
  final double todayCalories;
  final double todayDistanceKm;
  final int todayActiveMinutes;

  final int weekSteps;
  final double weekCalories;
  final double weekDistanceKm;
  final int weekActiveMinutes;

  const WearableActivitySummary({
    required this.todaySteps,
    required this.todayCalories,
    required this.todayDistanceKm,
    required this.todayActiveMinutes,
    required this.weekSteps,
    required this.weekCalories,
    required this.weekDistanceKm,
    required this.weekActiveMinutes,
  });

  factory WearableActivitySummary.empty() => const WearableActivitySummary(
        todaySteps: 0, todayCalories: 0, todayDistanceKm: 0, todayActiveMinutes: 0,
        weekSteps: 0, weekCalories: 0, weekDistanceKm: 0, weekActiveMinutes: 0,
      );

  bool get hasAnyData => weekSteps > 0 || weekCalories > 0 || weekDistanceKm > 0;

  String get todayTimeLabel {
    final h = todayActiveMinutes ~/ 60;
    final m = todayActiveMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}