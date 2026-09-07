import 'package:habitos_app/domain/datasources/habits_datasource.dart';
import 'package:habitos_app/domain/entities/habit.dart';
import 'package:habitos_app/domain/repositories/habits_repository.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsDatasource datasource;

  const HabitsRepositoryImpl(this.datasource);

  @override
  Future<List<Habit>> getTodayHabits() => datasource.getTodayHabits();

  @override
  Future<List<Habit>> getAllHabits() => datasource.getAllHabits();

  @override
  Future<Habit> updateProgress(String habitId, double newValue) =>
      datasource.updateProgress(habitId, newValue);

  @override
  Future<Habit> toggleActive(String habitId) =>
      datasource.toggleActive(habitId);

  @override
  Future<Habit> toggleCompleted(String habitId) =>
      datasource.toggleCompleted(habitId);

  @override
  Future<void> pauseHabit(String habitId) => datasource.pauseHabit(habitId);

  @override
  Future<void> saveHabit(Habit habit) => datasource.saveHabit(habit);

  @override
  Future<void> deleteHabit(String habitId) => datasource.deleteHabit(habitId);
}