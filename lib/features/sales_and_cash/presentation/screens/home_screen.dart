import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/pages/advisor_page.dart';
import 'package:tekki/features/advisor/presentation/widgets/advisor_health_badge.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/pages/passport_overview_page.dart';
import 'package:tekki/features/karne_bor/presentation/screens/karne_bor_screen.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/express_closure_screen.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/cash_card.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/primary_cta_button.dart';
import 'package:tekki/injection_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onCloseCashier});

  final VoidCallback? onCloseCashier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<CashDashboardBloc>();
    if (bloc.state is CashDashboardInitial) {
      bloc.add(const WatchCashDashboardStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashDashboardBloc, CashDashboardState>(
      listenWhen: (previous, current) {
        final wasLocked =
            previous is CashDashboardLoaded && previous.isClosureLocked;
        final isLocked =
            current is CashDashboardLoaded && current.isClosureLocked;
        return !wasLocked && isLocked;
      },
      listener: (context, state) async {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            key: ValueKey('closure_initiated_snackbar'),
            content: Text('🔒 Clôture de caisse initiée...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (widget.onCloseCashier != null) {
          widget.onCloseCashier!();
        } else {
          final result = await Navigator.of(context).push<DailyClosureEntity?>(
            MaterialPageRoute<DailyClosureEntity?>(
              builder: (_) => const ExpressClosureScreen(),
            ),
          );
          if (result == null && context.mounted) {
            context.read<CashDashboardBloc>().add(const ResetClosureLock());
          }
        }
      },
      builder: (context, state) {
        final isLoaded = state is CashDashboardLoaded;
        final isClosureLocked = isLoaded && state.isClosureLocked;
        final canClose = isLoaded && !state.isClosureLocked;

        return Scaffold(
          key: const ValueKey('home_screen'),
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Merchant header
                  _buildMerchantHeader(),
                  const SizedBox(height: 16),

                  // Discreet non-blocking error display if stream fails
                  if (state is CashDashboardError) ...[
                    _buildDiscreetErrorMessage(state.message),
                    const SizedBox(height: 12),
                  ],

                  // Cash Card
                  _buildCashCard(state),
                  const SizedBox(height: 16),

                  // Espace: Karné Bor
                  _buildPlaceholderCard(
                    key: const ValueKey('karne_bor_card'),
                    icon: Icons.menu_book_outlined,
                    title: 'Karné Bor',
                    subtitle: 'Gestion du crédit client & suivi des dettes',
                    badge: 'Actif',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const KarneBorScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Espace: Passeport Financier
                  _buildPlaceholderCard(
                    key: const ValueKey('passport_card'),
                    icon: Icons.verified_user_outlined,
                    title: 'Passeport Financier',
                    subtitle:
                        'Score de solvabilité & attestation D2D certifiée',
                    badge: 'Actif',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<PassportBloc>(),
                            child: const PassportOverviewPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Espace: Conseiller Tekki
                  _buildPlaceholderCard(
                    key: const ValueKey('conseiller_card'),
                    icon: Icons.insights_outlined,
                    title: 'Conseiller Tekki',
                    subtitle:
                        'Recommandations & santé financière de votre boutique',
                    badge: 'Actif',
                    customBadge: const AdvisorHealthBadge(
                      key: ValueKey('home_advisor_badge'),
                      status: HealthStatus.conforme,
                      compact: true,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<AdvisorCubit>(),
                            child: const AdvisorPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16), // Padding above bottom CTA
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.tertiary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: PrimaryCtaButton(
                key: const ValueKey('button-primary-cta'),
                isLocked: isClosureLocked,
                onPressed: canClose
                    ? () {
                        context.read<CashDashboardBloc>().add(
                          const CloseCashierTapped(),
                        );
                      }
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMerchantHeader() {
    return Container(
      key: const ValueKey('merchant_header'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Point de vente au comptoir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '100% Hors-ligne',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscreetErrorMessage(String message) {
    return Container(
      key: const ValueKey('cash_dashboard_error_banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning, width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Information de caisse temporairement indisponible. Vous pouvez continuer à enregistrer vos ventes.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaleRecorded(SaleEntity sale) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vente de ${sale.amount} FCFA enregistrée !'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCashCard(CashDashboardState state) {
    if (state is CashDashboardLoaded) {
      return CashCard(
        totalAmount: state.totalAmount,
        salesCount: state.salesCount,
        onSaleRecorded: _handleSaleRecorded,
      );
    }
    // Loading, initial, or discreet error fallback: displays 0 FCFA empty card with QuickSaleButton active
    return CashCard(
      totalAmount: 0,
      salesCount: 0,
      onSaleRecorded: _handleSaleRecorded,
    );
  }

  Widget _buildPlaceholderCard({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    VoidCallback? onTap,
    Widget? customBadge,
  }) {
    final card = Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (customBadge != null)
                      customBadge
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
