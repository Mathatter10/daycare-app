import 'package:flutter/material.dart';

/// Colors from docs/DESIGN_SYSTEM.md.
class AppColors {
  static const brand = Color(0xFF4F46E5);
  static const accent = Color(0xFF10B981);
  static const background = Color(0xFFF9FAFB);
  static const eat = Color(0xFFF59E0B);
  static const sleep = Color(0xFF3B82F6);
  static const toilet = Color(0xFF8B5CF6);
  static const play = Color(0xFFEC4899);
  static const medical = Color(0xFFEF4444);
  static const muted = Color(0xFF6B7280);
}

/// Thumb-zone primary buttons: full width, at least 56 px high.
const double primaryButtonHeight = 56;

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    primary: AppColors.brand,
    secondary: AppColors.accent,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.brand, foregroundColor: Colors.white, centerTitle: false),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(primaryButtonHeight),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(fontSize: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, showDragHandle: true),
  );
}
