import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/app.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/theme/app_theme.dart';

double _calculateRelativeLuminance(Color color) {
  double transform(double val) {
    return val <= 0.03928
        ? val / 12.92
        : pow((val + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = transform(color.r);
  final g = transform(color.g);
  final b = transform(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _calculateContrastRatio(Color c1, Color c2) {
  final l1 = _calculateRelativeLuminance(c1);
  final l2 = _calculateRelativeLuminance(c2);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppColors Tokens', () {
    test('Official Tekki palette hex codes are accurate', () {
      expect(AppColors.primary, const Color(0xFF133E59));
      expect(AppColors.secondary, const Color(0xFF387387));
      expect(AppColors.tertiary, const Color(0xFF8CB8C3));
      expect(AppColors.accent, const Color(0xFFFF7A41));
      expect(AppColors.accentSoft, const Color(0xFFFFAE90));
      expect(AppColors.background, const Color(0xFFFEECEA));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });

    test('WCAG AA contrast compliance on background and surface', () {
      final primaryOnBackground = _calculateContrastRatio(
        AppColors.primary,
        AppColors.background,
      );
      expect(primaryOnBackground, greaterThanOrEqualTo(4.5));

      final primaryOnSurface = _calculateContrastRatio(
        AppColors.primary,
        AppColors.surface,
      );
      expect(primaryOnSurface, greaterThanOrEqualTo(4.5));

      final secondaryOnSurface = _calculateContrastRatio(
        AppColors.secondary,
        AppColors.surface,
      );
      expect(secondaryOnSurface, greaterThanOrEqualTo(4.5));
    });
  });

  group('AppTheme Configuration', () {
    final theme = AppTheme.lightTheme;

    test('Scaffold and ColorScheme match official tokens', () {
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.tertiary, AppColors.tertiary);
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });

    test('ElevatedButton primary CTA has minHeight >= 52dp', () {
      final btnStyle = theme.elevatedButtonTheme.style;
      expect(btnStyle, isNotNull);
      final minSize = btnStyle!.minimumSize?.resolve({});
      expect(minSize, isNotNull);
      expect(minSize!.height, greaterThanOrEqualTo(52.0));
    });

    test('Typography tokens match DESIGN.md scale', () {
      final textTheme = theme.textTheme;

      // Display: 28px, 800
      expect(textTheme.displayLarge?.fontSize, 28);
      expect(textTheme.displayLarge?.fontWeight, FontWeight.w800);

      // Title: 20px, 800
      expect(textTheme.titleLarge?.fontSize, 20);
      expect(textTheme.titleLarge?.fontWeight, FontWeight.w800);

      // Headline: 16px, 700
      expect(textTheme.headlineMedium?.fontSize, 16);
      expect(textTheme.headlineMedium?.fontWeight, FontWeight.w700);

      // Body: 14px, 500
      expect(textTheme.bodyMedium?.fontSize, 14);
      expect(textTheme.bodyMedium?.fontWeight, FontWeight.w500);

      // Caption: 11px, 600
      expect(textTheme.bodySmall?.fontSize, 11);
      expect(textTheme.bodySmall?.fontWeight, FontWeight.w600);
    });
  });

  group('ThemeMode Locking (No Dark Mode)', () {
    testWidgets('TekkiApp enforces ThemeMode.light even when OS is in Dark Mode',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: TekkiApp(),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
      expect(materialApp.darkTheme, isNull);

      final BuildContext context = tester.element(find.byType(Scaffold));
      expect(Theme.of(context).brightness, Brightness.light);
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        AppColors.background,
      );
    });
  });
}
