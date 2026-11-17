import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';

/// Pastille synthétique discrète reflétant l'état de santé financière.
///
/// Respecte l'accessibilité visuelle en doublant la couleur par une icône de forme
/// et un symbole textuel explicite (✓ Vert = conforme, ⏳ Orange = attention, ! Rouge = urgent).
class AdvisorHealthBadge extends StatelessWidget {
  const AdvisorHealthBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.customLabel,
  });

  final HealthStatus status;
  final bool compact;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    final iconData = _getIconData(status);
    final label = customLabel ?? status.label;

    return Container(
      key: ValueKey('advisor_health_badge_${status.name}'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: compact ? 13 : 15, color: color),
          const SizedBox(width: 4),
          Text(
            compact ? '${status.symbol} $label' : '${status.symbol} $label',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Color _getColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.conforme:
        return AppColors.success;
      case HealthStatus.attention:
        return AppColors.warning;
      case HealthStatus.urgent:
        return AppColors.error;
    }
  }

  static IconData _getIconData(HealthStatus status) {
    switch (status) {
      case HealthStatus.conforme:
        return Icons.check_circle_outline;
      case HealthStatus.attention:
        return Icons.hourglass_top_rounded;
      case HealthStatus.urgent:
        return Icons.error_outline_rounded;
    }
  }
}
