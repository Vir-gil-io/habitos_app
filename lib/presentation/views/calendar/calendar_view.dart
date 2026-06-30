import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_rounded, size: 64, color: AppTheme.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Calendario',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Vista mensual de progreso\n(próximamente)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}