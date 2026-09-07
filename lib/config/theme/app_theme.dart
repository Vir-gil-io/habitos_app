import 'package:flutter/material.dart';

class AppTheme {
  // ── Paleta principal (compartida entre claro y oscuro) ───────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9D8DF1);
  static const Color primaryDark = Color(0xFF4A3AB5);

  static const Color completed = Color(0xFF00B894);
  static const Color pending = Color(0xFFE17055);
  static const Color streak = Color(0xFFFF7675);

  // ── Modo claro ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color divider = Color(0xFFDFE6E9);

  // ── Modo oscuro ────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF121218);
  static const Color surfaceDark = Color(0xFF1E1E28);
  static const Color textPrimaryDark = Color(0xFFF1F1F5);
  static const Color textSecondaryDark = Color(0xFFA0A0AC);
  static const Color dividerDark = Color(0xFF33333F);

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: completed,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 15, color: textSecondary),
          bodyMedium: TextStyle(fontSize: 13, color: textSecondary),
          labelSmall: TextStyle(fontSize: 11, color: textSecondary, letterSpacing: 0.5),
        ),
      );

  ThemeData getDarkTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primaryLight,
          secondary: completed,
          surface: surfaceDark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: textPrimaryDark,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surfaceDark,
          indicatorColor: primaryLight.withValues(alpha: 0.20),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryDark),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryDark),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryDark),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryDark),
          bodyLarge: TextStyle(fontSize: 15, color: textSecondaryDark),
          bodyMedium: TextStyle(fontSize: 13, color: textSecondaryDark),
          labelSmall: TextStyle(fontSize: 11, color: textSecondaryDark, letterSpacing: 0.5),
        ),
      );
}