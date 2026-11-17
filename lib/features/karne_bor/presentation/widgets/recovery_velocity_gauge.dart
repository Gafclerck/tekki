import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';

/// Jauge visuelle de santé financière du Karné Bor.
///
/// Respecte le Design System Tekki :
/// - Palette officielle et contrastes WCAG AA
/// - Indicateur de progression coloré selon le niveau de santé
/// - Badge de taux de recouvrement et message motivationnel bienveillant
class RecoveryVelocityGauge extends StatelessWidget {
  const RecoveryVelocityGauge({
    super.key,
    required this.velocity,
  });

  final RecoveryVelocityEntity velocity;

  Color _getStatusColor() {
    switch (velocity.healthLevel) {
      case RecoveryHealthLevel.excellent:
        return AppColors.success;
      case RecoveryHealthLevel.moderate:
        return AppColors.warning;
      case RecoveryHealthLevel.critical:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final progressValue = (velocity.rate / 100.0).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label: 'Santé du recouvrement : ${velocity.rate} pour cent. ${velocity.healthStatus}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.tertiary.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'SANTÉ DU RECOUVREMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  key: const ValueKey('recovery_velocity_badge'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recouvrement ${velocity.rate}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                key: const ValueKey('recovery_velocity_progress_bar'),
                value: progressValue,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  velocity.healthLevel == RecoveryHealthLevel.critical
                      ? Icons.warning_amber_rounded
                      : (velocity.healthLevel == RecoveryHealthLevel.moderate
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_outline_rounded),
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    velocity.healthStatus,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (velocity.totalDueAmount > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Recouvré dans les délais : ${CurrencyFormatter.format(velocity.totalRecoveredAmount)} / ${CurrencyFormatter.format(velocity.totalDueAmount)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
