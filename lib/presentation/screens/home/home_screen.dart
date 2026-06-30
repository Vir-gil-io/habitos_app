import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/views/home/home_view.dart';
import 'package:habitos_app/presentation/widgets/shared/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const HomeView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navegar a pantalla de agregar hábito
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}