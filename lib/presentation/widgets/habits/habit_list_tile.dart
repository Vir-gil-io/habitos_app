import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/domain/entities/habit.dart';

class HabitListTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onStart;
  final VoidCallback onToggleCompleted;
  final VoidCallback? onTap;

  const HabitListTile({
    super.key,
    required this.habit,
    required this.onStart,
    required this.onToggleCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _categoryIcon(habit.category),
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            style:
                                textTheme.titleMedium?.copyWith(
                                  decoration: habit.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ) ??
                                const TextStyle(),
                            child: Text(habit.name),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Al menos ${habit.goalLabel} · ${habit.repeatLabel}',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: onStart,
              onLongPress: onToggleCompleted,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: habit.isCompleted
                      ? AppTheme.completed.withValues(alpha: 0.15)
                      : AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  habit.isCompleted
                      ? Icons.check_rounded
                      : habit.isActive
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: habit.isCompleted ? AppTheme.completed : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(HabitCategory cat) {
    return switch (cat) {
      HabitCategory.cognitive => Icons.menu_book_rounded,
      HabitCategory.physical => Icons.fitness_center_rounded,
      HabitCategory.hydration => Icons.water_drop_rounded,
      HabitCategory.productivity => Icons.school_rounded,
      HabitCategory.rest => Icons.bedtime_rounded,
    };
  }
}
