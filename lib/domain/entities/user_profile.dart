class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;
  final double? heightCm;
  final double? weightKg;
  final int? ageYears;
  final int globalStreakDays;
  final int totalStepsWeek;
  final double totalCaloriesWeek;
  final double totalDistanceMilesWeek;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedAt,
    this.heightCm,
    this.weightKg,
    this.ageYears,
    this.globalStreakDays = 0,
    this.totalStepsWeek = 0,
    this.totalCaloriesWeek = 0,
    this.totalDistanceMilesWeek = 0,
  });

  /// true si el usuario aún no ha completado sus datos físicos
  bool get isMissingPhysicalData =>
      heightCm == null || weightKg == null || ageYears == null;
}