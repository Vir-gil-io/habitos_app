import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app/config/config.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HabitosApp(),
    ),
  );
}

class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
    );
  }
}