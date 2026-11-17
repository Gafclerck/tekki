import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';

class PassportScoreBadgeCard extends StatelessWidget {
  const PassportScoreBadgeCard({super.key, required this.passport});

  final FinancialPassportEntity passport;

  String _getRankLabel(int score) {
    if (score >= 80) return 'Excellente fiabilité';
    if (score >= 65) return 'Très bonne régularité';
    if (score >= 50) return 'Activité en croissance';
    return 'Démarrage d\'activité';
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = passport.breakdown;

    return Container(
      key: const ValueKey('passport_score_badge_card'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PASSEPORT FINANCIER TEKKI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.tertiary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.accent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Série : ${passport.streak} j',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Score principal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${passport.overallScore}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.25),
                  border: Border.all(color: AppColors.tertiary, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRankLabel(passport.overallScore),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pilules des 4 piliers
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPill(
                icon: Icons.event_available,
                label: 'Clôtures',
                score: breakdown.closureScore,
              ),
              _buildPill(
                icon: Icons.payments_outlined,
                label: 'Karné Bor',
                score: breakdown.debtScore,
              ),
              _buildPill(
                icon: Icons.location_on_outlined,
                label: 'GPS Boutique',
                score: breakdown.gpsScore,
              ),
              _buildPill(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Discipline Caisse',
                score: breakdown.cashScore,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.tertiary, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label : $score/100',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
