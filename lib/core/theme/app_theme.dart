import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.surface,
        error: AppColors.error,
        onError: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.tertiary, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(52),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 34 / 28,
          color: AppColors.primary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 26 / 20,
          color: AppColors.primary,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 22 / 16,
          color: AppColors.primary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: AppColors.primary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 15 / 11,
          color: AppColors.secondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 15 / 11,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
