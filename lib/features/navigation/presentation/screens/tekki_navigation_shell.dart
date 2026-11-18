import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/widgets/demo_data_dialog.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/pages/advisor_page.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/pages/passport_overview_page.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_cubit.dart';
import 'package:tekki/features/financing/presentation/pages/financing_page.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/screens/karne_bor_screen.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/home_screen.dart';
import 'package:tekki/features/sync/presentation/widgets/sync_status_indicator.dart';
import 'package:tekki/injection_container.dart';

class TekkiNavigationShell extends StatefulWidget {
  const TekkiNavigationShell({
    super.key,
    this.initialIndex = 0,
    this.cashDashboardBloc,
    this.financingCubit,
    this.passportBloc,
  });

  final int initialIndex;
  final CashDashboardBloc? cashDashboardBloc;
  final FinancingCubit? financingCubit;
  final PassportBloc? passportBloc;

  @override
  State<TekkiNavigationShell> createState() => _TekkiNavigationShellState();
}

class _TekkiNavigationShellState extends State<TekkiNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTabSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Facilitation au Crédit & Prêts';
      case 1:
        return 'Passeport & Solvabilité';
      case 2:
        return 'Caisse & Point de Vente';
      case 3:
        return 'Karné Bor (Dettes & Crédits)';
      case 4:
        return 'Conseiller & Santé Financière';
      default:
        return AppConstants.appName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 640;

        final body = IndexedStack(
          index: _currentIndex,
          children: [
            // Onglet 0: Financement (Hero Tab)
            FinancingPage(
              cubit: widget.financingCubit,
              onNavigateToPassport: () => _onDestinationSelected(1),
            ),

            // Onglet 1: Passeport Financier
            if (widget.passportBloc != null)
              BlocProvider.value(
                value: widget.passportBloc!,
                child: const PassportOverviewPage(showBackButton: false),
              )
            else if (sl.isRegistered<PassportBloc>())
              BlocProvider(
                create: (_) => sl<PassportBloc>(),
                child: const PassportOverviewPage(showBackButton: false),
              )
            else
              const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: Text('Passeport Financier')),
              ),

            // Onglet 2: Caisse & Point de vente (Gestion boutique secondaire)
            if (widget.cashDashboardBloc != null)
              BlocProvider.value(
                value: widget.cashDashboardBloc!,
                child: const HomeScreen(),
              )
            else if (sl.isRegistered<CashDashboardBloc>())
              BlocProvider(
                create: (_) => sl<CashDashboardBloc>(),
                child: const HomeScreen(),
              )
            else
              const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: Text('Caisse & Point de Vente')),
              ),

            // Onglet 3: Karné Bor (Dettes clients)
            if (sl.isRegistered<WatchActiveDebtsUseCase>())
              const KarneBorScreen(showBackButton: false)
            else
              const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: Text('Karné Bor')),
              ),

            // Onglet 4: Conseiller Tekki
            if (sl.isRegistered<AdvisorCubit>())
              BlocProvider(
                create: (_) => sl<AdvisorCubit>(),
                child: const AdvisorPage(),
              )
            else
              const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: Text('Conseiller Tekki')),
              ),
          ],
        );

        final appBar = AppBar(
          key: const ValueKey('tekki_shell_app_bar'),
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _getTabSubtitle(_currentIndex),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          actions: [
            // Bouton de Test & Démo
            IconButton(
              key: const ValueKey('demo_data_action_button'),
              tooltip: 'Données de Test & Démo',
              icon: const Icon(
                Icons.science_outlined,
                color: AppColors.accent,
                size: 22,
              ),
              onPressed: () {
                DemoDataDialog.show(
                  context,
                  onDataChanged: () {
                    setState(() {});
                  },
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SyncStatusIndicator(),
            ),
          ],
        );

        if (isWideScreen) {
          return Scaffold(
            key: const ValueKey('tekki_shell_scaffold_wide'),
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  key: const ValueKey('tekki_navigation_rail'),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  backgroundColor: AppColors.surface,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.accent,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: AppColors.secondary,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_outlined),
                      selectedIcon: Icon(Icons.account_balance_rounded),
                      label: Text('Financement'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.verified_user_outlined),
                      selectedIcon: Icon(Icons.verified_user_rounded),
                      label: Text('Passeport'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.point_of_sale_outlined),
                      selectedIcon: Icon(Icons.point_of_sale_rounded),
                      label: Text('Caisse'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded),
                      label: Text('Karné Bor'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights_rounded),
                      label: Text('Conseiller'),
                    ),
                  ],
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: AppColors.tertiary,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          key: const ValueKey('tekki_shell_scaffold_mobile'),
          backgroundColor: AppColors.background,
          appBar: appBar,
          body: body,
          bottomNavigationBar: NavigationBar(
            key: const ValueKey('tekki_bottom_navigation_bar'),
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.accent.withValues(alpha: 0.18),
            elevation: 3,
            destinations: const [
              NavigationDestination(
                key: ValueKey('nav_financement'),
                icon: Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.secondary,
                ),
                selectedIcon: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.accent,
                ),
                label: 'Financement',
              ),
              NavigationDestination(
                key: ValueKey('nav_passeport'),
                icon: Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.secondary,
                ),
                selectedIcon: Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.accent,
                ),
                label: 'Passeport',
              ),
              NavigationDestination(
                key: ValueKey('nav_caisse'),
                icon: Icon(
                  Icons.point_of_sale_outlined,
                  color: AppColors.secondary,
                ),
                selectedIcon: Icon(
                  Icons.point_of_sale_rounded,
                  color: AppColors.accent,
                ),
                label: 'Caisse',
              ),
              NavigationDestination(
                key: ValueKey('nav_karne_bor'),
                icon: Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.secondary,
                ),
                selectedIcon: Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.accent,
                ),
                label: 'Karné Bor',
              ),
              NavigationDestination(
                key: ValueKey('nav_conseiller'),
                icon: Icon(Icons.insights_outlined, color: AppColors.secondary),
                selectedIcon: Icon(
                  Icons.insights_rounded,
                  color: AppColors.accent,
                ),
                label: 'Conseiller',
              ),
            ],
          ),
        );
      },
    );
  }
}
