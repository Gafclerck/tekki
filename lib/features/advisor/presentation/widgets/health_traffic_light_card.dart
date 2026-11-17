import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/health_indicator_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';
import 'package:tekki/features/advisor/presentation/widgets/advisor_health_badge.dart';

/// Carte visuelle de diagnostic d'un axe de gestion pour le Conseiller Tekki.
///
/// Restitue le statut sous forme de feu tricolore doublé d'une icône de forme
/// pour l'accessibilité visuelle, avec le constat bienveillant et la recommandation concrète.
class HealthTrafficLightCard extends StatelessWidget {
  const HealthTrafficLightCard({super.key, required this.indicator});

  final HealthIndicatorEntity indicator;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(indicator.status);

    return Container(
      key: ValueKey('health_indicator_card_${indicator.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne d'en-tête : Icône de métrique, Titre et Badge tricolore doublé
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getMetricIcon(indicator.id),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      indicator.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AdvisorHealthBadge(status: indicator.status, compact: true),
                ],
              ),
              const SizedBox(height: 12),

              // Diagnostic bienveillant
              Text(
                indicator.diagnostic,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),

              // Boîte de recommandation concrète
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        indicator.recommendation,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.conforme:
        return AppColors.success;
      case HealthStatus.attention:
        return AppColors.warning;
      case HealthStatus.urgent:
        return AppColors.error;
    }
  }

  static IconData _getMetricIcon(String id) {
    switch (id) {
      case 'caisse_regularity':
        return Icons.lock_clock_outlined;
      case 'karne_bor_recovery':
        return Icons.menu_book_outlined;
      case 'cash_discipline':
        return Icons.account_balance_wallet_outlined;
      case 'location_stability':
        return Icons.location_on_outlined;
      default:
        return Icons.insights_outlined;
    }
  }
}
