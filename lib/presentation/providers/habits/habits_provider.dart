import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:habitos_app/domain/entities/habit.dart';
import 'package:habitos_app/infrastructure/datasource/local_habits_datasource_impl.dart';
import 'package:habitos_app/infrastructure/repositories/habits_repository_impl.dart';

// ── Repositorio ────────────────────────────────────────────────────────────
final habitsRepositoryProvider = Provider((ref) {
  return HabitsRepositoryImpl(LocalHabitsDatasourceImpl());
});

// ── Notifier ───────────────────────────────────────────────────────────────
class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final Ref _ref;

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(habitsRepositoryProvider);
      final habits = await repo.getTodayHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleActive(String habitId) async {
    final repo = _ref.read(habitsRepositoryProvider);
    final updated = await repo.toggleActive(habitId);
    state = state.whenData((habits) {
      return habits.map((h) => h.id == habitId ? updated : h).toList();
    });
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitsNotifier(ref);
});

// ── Derivados ──────────────────────────────────────────────────────────────
final pendingHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (habits) => habits.where((h) => !h.isCompleted).toList(),
        orElse: () => [],
      );
});

final completedHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (habits) => habits.where((h) => h.isCompleted).toList(),
        orElse: () => [],
      );
});

final activeStreakProvider = Provider<int>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (habits) =>
            habits.isNotEmpty ? habits.first.streakDays : 0,
        orElse: () => 0,
      );
});

final nextHabitProvider = Provider<Habit?>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (habits) {
          final pending = habits
              .where((h) => !h.isCompleted && h.scheduledTime != null)
              .toList()
            ..sort((a, b) =>
                a.scheduledTime!.compareTo(b.scheduledTime!));
          return pending.isNotEmpty ? pending.first : null;
        },
        orElse: () => null,
      );
});