import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app/presentation/providers/providers.dart';
import 'package:habitos_app/services/wear_sync_channel.dart';

class WearSyncGate extends ConsumerStatefulWidget {
  final Widget child;
  const WearSyncGate({super.key, required this.child});

  @override
  ConsumerState<WearSyncGate> createState() => _WearSyncGateState();
}

class _WearSyncGateState extends ConsumerState<WearSyncGate> {
  bool _listenersAttached = false;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider).maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );

    if (authUser != null && !_listenersAttached) {
      _listenersAttached = true;

      // Escucha cambios futuros
      ref.listen(habitsProvider, (_, next) => _pushSync());
      ref.listen(remindersProvider, (_, next) => _pushSync());
      ref.listen(profileProvider, (_, next) => _pushSync());

      // Envía el estado actual de inmediato, después de este frame
      // (evita "setState during build" al llamar _pushSync directamente aquí)
      WidgetsBinding.instance.addPostFrameCallback((_) => _pushSync());
    }

    if (authUser == null) {
      _listenersAttached = false; // permite re-adjuntar tras un logout/login
    }

    return widget.child;
  }

  void _pushSync() {
    final habits = ref.read(habitsProvider).maybeWhen(
      data: (h) => h,
      orElse: () => null,
    );
    if (habits == null) return;

    final streak = ref.read(activeStreakProvider);

    final reminders = ref.read(remindersProvider).maybeWhen(
      data: (r) => r,
      orElse: () => [],
    );

    final payload = {
      'streak': streak,
      'habits': habits.map((h) => {
            'name': h.name,
            'current_value': h.currentValue,
            'goal_value': h.goalValue,
            'unit': h.unit.name,
            'scheduled_time': h.scheduledTime?.toIso8601String(),
          }).toList(),
      'reminders': reminders.take(3).map((r) => {
            'title': r.title,
            'date': '${r.date.year}-'
                '${r.date.month.toString().padLeft(2, '0')}-'
                '${r.date.day.toString().padLeft(2, '0')}',
            'time_of_day': r.time != null
                ? '${r.time!.hour.toString().padLeft(2, '0')}:'
                    '${r.time!.minute.toString().padLeft(2, '0')}'
                : null,
          }).toList(),
    };

    WearSyncChannel.sync(payload);
  }
}