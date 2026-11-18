import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/navigation/presentation/screens/tekki_navigation_shell.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/home_screen.dart';
import 'package:tekki/injection_container.dart';

class TekkiApp extends StatelessWidget {
  const TekkiApp({super.key, this.cashDashboardBloc, this.initialIndex = 0});

  final CashDashboardBloc? cashDashboardBloc;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (cashDashboardBloc != null && !sl.isRegistered<CashDashboardBloc>()) {
      return BlocProvider.value(
        value: cashDashboardBloc!,
        child: const HomeScreen(),
      );
    }
    if (sl.isRegistered<CashDashboardBloc>()) {
      return TekkiNavigationShell(
        cashDashboardBloc: cashDashboardBloc,
        initialIndex: initialIndex,
      );
    }
    // Fallback when DI is not initialized (e.g. in theme-only or isolated tests)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/branding/logo_symbol.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
