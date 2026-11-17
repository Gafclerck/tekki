import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/home_screen.dart';
import 'package:tekki/injection_container.dart';

class TekkiApp extends StatelessWidget {
  const TekkiApp({super.key, this.cashDashboardBloc});

  final CashDashboardBloc? cashDashboardBloc;

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
    if (cashDashboardBloc != null) {
      return BlocProvider.value(
        value: cashDashboardBloc!,
        child: const HomeScreen(),
      );
    }
    if (sl.isRegistered<CashDashboardBloc>()) {
      return BlocProvider(
        create: (_) => sl<CashDashboardBloc>(),
        child: const HomeScreen(),
      );
    }
    // Fallback when DI is not initialized (e.g. in theme-only or isolated tests)
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text(AppConstants.appName)),
    );
  }
}
