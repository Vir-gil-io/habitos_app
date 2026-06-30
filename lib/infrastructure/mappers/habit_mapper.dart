import 'package:habitos_app/domain/entities/habit.dart';
import 'package:habitos_app/infrastructure/models/habit_model.dart';

class HabitMapper {
  static Habit fromModel(HabitModel model) => Habit(
        id: model.id,
        name: model.name,
        category: _parseCategory(model.category),
        goalValue: model.goalValue,
        unit: _parseUnit(model.unit),
        currentValue: model.currentValue,
        isActive: model.isActive,
        streakDays: model.streakDays,
        scheduledTime: model.scheduledTime != null
            ? DateTime.tryParse(model.scheduledTime!)
            : null,
      );

  static HabitModel toModel(Habit entity) => HabitModel(
        id: entity.id,
        name: entity.name,
        category: entity.category.name,
        goalValue: entity.goalValue,
        unit: entity.unit.name,
        currentValue: entity.currentValue,
        isActive: entity.isActive,
        streakDays: entity.streakDays,
        scheduledTime: entity.scheduledTime?.toIso8601String(),
      );

  static HabitCategory _parseCategory(String raw) {
    return HabitCategory.values.firstWhere(
      (c) => c.name == raw,
      orElse: () => HabitCategory.physical,
    );
  }

  static HabitUnit _parseUnit(String raw) {
    return HabitUnit.values.firstWhere(
      (u) => u.name == raw,
      orElse: () => HabitUnit.minutes,
    );
  }
}