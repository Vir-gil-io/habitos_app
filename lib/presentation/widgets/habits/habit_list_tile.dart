import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/domain/entities/habit.dart';

class HabitListTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onStart;

  const HabitListTile({super.key, required this.habit, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _categoryIcon(habit.category),
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Nombre y meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Al menos ${habit.goalLabel}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Botón start
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
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