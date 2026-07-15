import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/views/home/home_view.dart';
import 'package:habitos_app/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:habitos_app/presentation/widgets/habits/add_habit_sheet.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const HomeView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddHabit(context);
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Agregar hábito',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}