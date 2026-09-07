import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/domain/entities/habit.dart';
import 'package:habitos_app/presentation/providers/providers.dart';
import 'package:habitos_app/presentation/widgets/home/activity_card.dart';
import 'package:habitos_app/presentation/widgets/habits/edit_habit_sheet.dart';

class ActivityStatisticsScreen extends ConsumerWidget {
  const ActivityStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final textTheme = Theme.of(context).textTheme;

    final allHabits =
        habitsAsync.maybeWhen(data: (h) => h, orElse: () => <Habit>[]);
    final completed = allHabits.where((h) => h.isCompleted).length;
    final total     = allHabits.length;

    int cognitive = 0, physical = 0, hydration = 0,
        productivity = 0, rest = 0;
    for (final h in allHabits) {
      switch (h.category) {
        case HabitCategory.cognitive:    cognitive++;    break;
        case HabitCategory.physical:     physical++;     break;
        case HabitCategory.hydration:    hydration++;    break;
        case HabitCategory.productivity: productivity++; break;
        case HabitCategory.rest:         rest++;         break;
      }
    }
    double pct(int n) => total == 0 ? 0 : n / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Activity Statistics'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorías totales
            Center(
              child: Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  const Text('🔥', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  Text('$completed de $total hábitos completados hoy',
                      style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Builder(builder: (context) {
                    final activity = ref.watch(wearableActivityProvider).maybeWhen(
                      data: (a) => a,
                      orElse: () => null,
                    );
                    final cal = activity?.todayCalories ?? 0;
                    return Text(
                      cal > 0
                          ? '${cal.toStringAsFixed(0)} kcal quemadas hoy'
                          : 'Calorías disponibles cuando conectes el wearable',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _CategoryBar(label: 'Cognitivo',     percent: pct(cognitive),    color: AppTheme.primary),
            _CategoryBar(label: 'Físico',        percent: pct(physical),     color: AppTheme.completed),
            _CategoryBar(label: 'Hidratación',   percent: pct(hydration),    color: const Color(0xFF0984E3)),
            _CategoryBar(label: 'Productividad', percent: pct(productivity), color: AppTheme.pending),
            _CategoryBar(label: 'Descanso',      percent: pct(rest),         color: AppTheme.streak),

            const SizedBox(height: 20),

            // Distancia
            Builder(builder: (context) {
              final activity = ref.watch(wearableActivityProvider).maybeWhen(
                data: (a) => a,
                orElse: () => null,
              );
              final km = activity?.todayDistanceKm ?? 0;
              return Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text('Has recorrido ', style: textTheme.bodyLarge),
                  Text(
                    '${km.toStringAsFixed(2)} km',
                    style: textTheme.titleMedium?.copyWith(color: AppTheme.primary),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),

            // Pasos y tiempo
            Builder(builder: (context) {
              final activity = ref.watch(wearableActivityProvider).maybeWhen(
                data: (a) => a,
                orElse: () => null,
              );
              return Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.directions_walk_rounded,
                      value: activity != null ? '${activity.todaySteps}' : '—',
                      label: 'pasos',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.access_time_rounded,
                      value: activity?.todayTimeLabel ?? '—',
                      label: 'tiempo activo',
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),
            Text('Your Activities', style: textTheme.titleLarge),
            const SizedBox(height: 8),

            habitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (habits) => Column(
                children: habits
                    .take(10)   // ← máximo 10
                    .map(
                      (h) => ActivityCard(
                        habit: h,
                        onToggle: () => ref
                            .read(habitsProvider.notifier)
                            .toggleActive(h.id),
                        onToggleCompleted: () => ref
                            .read(habitsProvider.notifier)
                            .toggleCompleted(h.id),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => EditHabitSheet(habit: h),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _CategoryBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percent * 100).toInt()}%',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
