import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';
import 'package:tekki/features/advisor/presentation/widgets/advisor_health_badge.dart';
import 'package:tekki/features/advisor/presentation/widgets/audio_capsule_card.dart';
import 'package:tekki/features/advisor/presentation/widgets/health_traffic_light_card.dart';

/// Page principale du Conseiller Tekki.
///
/// Restitue le diagnostic complet d'audit de santé financière en 4 repères visuels
/// sous forme de feux tricolores (Vert/Orange/Rouge) doublés d'icônes de forme.
class AdvisorPage extends StatefulWidget {
  const AdvisorPage({super.key});

  @override
  State<AdvisorPage> createState() => _AdvisorPageState();
}

class _AdvisorPageState extends State<AdvisorPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdvisorCubit>();
    if (cubit.state is AdvisorInitial) {
      cubit.loadFinancialHealth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('advisor_page'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  'assets/branding/logo_symbol.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Text(
              'Conseiller Tekki',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: BlocBuilder<AdvisorCubit, AdvisorState>(
          builder: (context, state) {
            return switch (state) {
              AdvisorInitial() || AdvisorLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              AdvisorError(message: final msg) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<AdvisorCubit>().loadFinancialHealth();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AdvisorLoaded(financialHealth: final health) => _buildContent(
                context,
                health,
              ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinancialHealthEntity health) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte résumé de santé financière
          _buildOverallSummaryCard(health),
          const SizedBox(height: 16),

          // Capsule audio éducative bilingue
          const AudioCapsuleCard(),
          const SizedBox(height: 20),

          // Titre de section
          const Text(
            '4 Repères de gestion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Feux tricolores d\'accessibilité et conseils pratiques',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),

          // Liste des 4 indicateurs
          ...health.indicators.map(
            (indicator) => HealthTrafficLightCard(indicator: indicator),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOverallSummaryCard(FinancialHealthEntity health) {
    return Container(
      key: const ValueKey('advisor_overall_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bilan Global',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              AdvisorHealthBadge(status: health.overallStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            health.summary,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
