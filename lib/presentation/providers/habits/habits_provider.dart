import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:habitos_app/domain/entities/habit.dart';
import 'package:habitos_app/infrastructure/datasource/supabase_habits_datasource_impl.dart';
import 'package:habitos_app/infrastructure/repositories/habits_repository_impl.dart';
import 'package:habitos_app/presentation/providers/auth/auth_provider.dart';
import 'package:habitos_app/presentation/providers/profile/profile_provider.dart';

final habitsRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HabitsRepositoryImpl(SupabaseHabitsDatasourceImpl(client));
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHabits();
    _startTicker();
  }

  final Ref _ref;
  Timer? _ticker;
  DateTime _lastTick = DateTime.now();
  DateTime _lastSync = DateTime.now();

  static const _syncInterval = Duration(seconds: 8);

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _ref.read(habitsRepositoryProvider).getTodayHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleActive(String habitId) async {
    try {
      final updated =
          await _ref.read(habitsRepositoryProvider).toggleActive(habitId);
      state = state.whenData(
        (list) => list.map((h) => h.id == habitId ? updated : h).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleCompleted(String habitId) async {
    try {
      final repo = _ref.read(habitsRepositoryProvider);
      final updated = await repo.toggleCompleted(habitId);
      state = state.whenData(
        (list) => list.map((h) => h.id == habitId ? updated : h).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _ref.read(habitsRepositoryProvider).deleteHabit(habitId);
      state = state.whenData(
        (list) => list.where((h) => h.id != habitId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createHabit({
    required String name,
    required HabitCategory category,
    required double goalValue,
    required HabitUnit unit,
    DateTime? scheduledTime,
    List<int> repeatDays = const [1, 2, 3, 4, 5, 6, 7],
  }) async {
    try {
      final habit = Habit(
        id: '',
        name: name,
        category: category,
        goalValue: goalValue,
        unit: unit,
        scheduledTime: scheduledTime,
        repeatDays: repeatDays,
      );
      await _ref.read(habitsRepositoryProvider).saveHabit(habit);
      await loadHabits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Cronómetro real de progreso ──────────────────────────────────────────
  // Mientras un hábito con unidad "minutos" está activo (is_active = true),
  // este ticker incrementa su progreso cada segundo con tiempo real
  // transcurrido, para que la barra se llene visualmente en vivo.
  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    state.whenData((habits) {
      var changed = false;
      final updated = habits.map((h) {
        if (h.isActive && !h.isCompleted && h.unit == HabitUnit.minutes) {
          final incrementMinutes = elapsedSeconds / 60.0;
          final newValue =
              (h.currentValue + incrementMinutes).clamp(0.0, h.goalValue);
          changed = true;
          return h.copyWith(currentValue: newValue);
        }
        return h;
      }).toList();

      if (changed) {
        state = AsyncValue.data(updated);
      }
    });

    if (now.difference(_lastSync) >= _syncInterval) {
      _lastSync = now;
      _syncActiveProgress();
    }
  }

  /// Persiste en Supabase el progreso acumulado de los hábitos que están
  /// corriendo por tiempo. Se ejecuta cada pocos segundos (no cada tick)
  /// para no saturar la base de datos con escrituras por segundo.
  Future<void> _syncActiveProgress() async {
    final habits = state.maybeWhen(data: (h) => h, orElse: () => <Habit>[]);
    final repo = _ref.read(habitsRepositoryProvider);

    for (final h in habits) {
      if (h.isActive && h.unit == HabitUnit.minutes) {
        try {
          await repo.updateProgress(h.id, h.currentValue);
          if (h.currentValue >= h.goalValue) {
            await repo.pauseHabit(h.id);
          }
        } catch (_) {
          // Se reintenta en el siguiente ciclo de sincronización
        }
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitsNotifier(ref);
});

final pendingHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (list) => list.where((h) => !h.isCompleted).toList(),
        orElse: () => [],
      );
});

final completedHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (list) => list.where((h) => h.isCompleted).toList(),
        orElse: () => [],
      );
});

final activeStreakProvider = Provider<int>((ref) {
  return ref.watch(profileProvider).maybeWhen(
        data: (profile) => profile?.globalStreakDays ?? 0,
        orElse: () => 0,
      );
});

final nextHabitProvider = Provider<Habit?>((ref) {
  return ref.watch(habitsProvider).maybeWhen(
        data: (list) {
          final now = DateTime.now();
          final pending = list
              .where((h) => !h.isCompleted && h.scheduledTime != null)
              .toList()
            ..sort((a, b) => a.scheduledTime!.compareTo(b.scheduledTime!));

          final upcoming = pending.where((h) {
            final t = h.scheduledTime!;
            final scheduledToday =
                DateTime(now.year, now.month, now.day, t.hour, t.minute);
            return !scheduledToday.isBefore(now);
          }).toList();

          if (upcoming.isNotEmpty) return upcoming.first;
          return pending.isNotEmpty ? pending.first : null;
        },
        orElse: () => null,
      );
});