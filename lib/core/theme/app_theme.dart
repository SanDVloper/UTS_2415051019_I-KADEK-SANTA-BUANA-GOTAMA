import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Standard Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // High Contrast Theme (WCAG AAA)
  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.hcBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.hcPrimary,
        secondary: AppColors.hcSecondary,
        surface: AppColors.hcSurface,
        error: Color(0xFFFF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.hcSurface,
        foregroundColor: AppColors.hcTextMain,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.hcSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.hcBorder, width: 2),
        ),
      ),
    );
  }
}
