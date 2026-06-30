import 'package:flutter/material.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/views/profile/profile_view.dart';
import 'package:habitos_app/presentation/widgets/shared/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Tu Perfil'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: const ProfileView(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}