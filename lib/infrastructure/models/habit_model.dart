class HabitModel {
  final String id;
  final String name;
  final String category;
  final double goalValue;
  final String unit;
  final double currentValue;
  final bool isActive;
  final int streakDays;
  final String? scheduledTime;
  final List<int> repeatDays;

  const HabitModel({
    required this.id,
    required this.name,
    required this.category,
    required this.goalValue,
    required this.unit,
    this.currentValue = 0,
    this.isActive = false,
    this.streakDays = 0,
    this.scheduledTime,
    this.repeatDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        goalValue: (json['goalValue'] as num).toDouble(),
        unit: json['unit'] as String,
        currentValue: (json['currentValue'] as num? ?? 0).toDouble(),
        isActive: json['isActive'] as bool? ?? false,
        streakDays: json['streakDays'] as int? ?? 0,
        scheduledTime: json['scheduledTime'] as String?,
        repeatDays: (json['repeatDays'] as List?)
                ?.map((e) => e as int)
                .toList() ??
            const [1, 2, 3, 4, 5, 6, 7],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'goalValue': goalValue,
        'unit': unit,
        'currentValue': currentValue,
        'isActive': isActive,
        'streakDays': streakDays,
        'scheduledTime': scheduledTime,
        'repeatDays': repeatDays,
      };
}