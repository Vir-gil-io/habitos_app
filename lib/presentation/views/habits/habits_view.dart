import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/providers/providers.dart';
import 'package:habitos_app/presentation/widgets/widgets.dart';
import 'package:habitos_app/presentation/widgets/habits/edit_habit_sheet.dart';

class HabitsView extends ConsumerWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checklist_rtl_rounded,
                    size: 64, color: AppTheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('Sin hábitos registrados',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Toca el botón + para crear tu primer hábito',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 80),
          children: habits
              .map(
                (h) => HabitListTile(
                  habit: h,
                  onStart: () =>
                      ref.read(habitsProvider.notifier).toggleActive(h.id),
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
        );
      },
    );
  }
}