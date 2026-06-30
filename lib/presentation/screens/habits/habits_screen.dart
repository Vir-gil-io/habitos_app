import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/views/habits/habits_view.dart';
import 'package:habitos_app/presentation/widgets/shared/bottom_nav_bar.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hábitos'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: const HabitsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: agregar nuevo hábito
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}