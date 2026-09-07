import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app/domain/entities/wearable_activity_summary.dart';
import 'package:habitos_app/presentation/providers/auth/auth_provider.dart';

class WearableActivityNotifier
    extends StateNotifier<AsyncValue<WearableActivitySummary>> {
  WearableActivityNotifier(this._client)
      : super(const AsyncValue.loading()) {
    load();
    _subscribeToRealtime();
  }

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        state = AsyncValue.data(WearableActivitySummary.empty());
        return;
      }

      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final mondayStr = _fmt(monday);
      final todayStr = _fmt(now);

      final rows = await _client
          .from('wearable_activity')
          .select()
          .eq('user_id', uid)
          .gte('date', mondayStr)
          .order('date', ascending: true);

      int weekSteps = 0, weekActiveMinutes = 0;
      double weekCalories = 0, weekDistanceKm = 0;
      int todaySteps = 0, todayActiveMinutes = 0;
      double todayCalories = 0, todayDistanceKm = 0;

      for (final row in rows) {
        final steps = row['steps'] as int? ?? 0;
        final calories = (row['calories'] as num?)?.toDouble() ?? 0;
        final distance = (row['distance_km'] as num?)?.toDouble() ?? 0;
        final active = row['active_minutes'] as int? ?? 0;

        weekSteps += steps;
        weekCalories += calories;
        weekDistanceKm += distance;
        weekActiveMinutes += active;

        if (row['date'] as String == todayStr) {
          todaySteps = steps;
          todayCalories = calories;
          todayDistanceKm = distance;
          todayActiveMinutes = active;
        }
      }

      state = AsyncValue.data(WearableActivitySummary(
        todaySteps: todaySteps,
        todayCalories: todayCalories,
        todayDistanceKm: todayDistanceKm,
        todayActiveMinutes: todayActiveMinutes,
        weekSteps: weekSteps,
        weekCalories: weekCalories,
        weekDistanceKm: weekDistanceKm,
        weekActiveMinutes: weekActiveMinutes,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Escucha inserts/updates en tiempo real de la fila del usuario
  /// actual en wearable_activity y recarga el resumen automáticamente,
  /// sin necesidad de pull-to-refresh manual.
  void _subscribeToRealtime() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    _channel = _client
        .channel('wearable_activity_changes_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'wearable_activity',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) => load(),
        )
        .subscribe();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    if (_channel != null) {
      _client.removeChannel(_channel!);
    }
    super.dispose();
  }
}

final wearableActivityProvider = StateNotifierProvider<
    WearableActivityNotifier, AsyncValue<WearableActivitySummary>>((ref) {
  return WearableActivityNotifier(ref.watch(supabaseClientProvider));
});