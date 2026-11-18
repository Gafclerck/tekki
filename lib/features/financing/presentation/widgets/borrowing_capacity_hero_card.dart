import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';

class BorrowingCapacityHeroCard extends StatelessWidget {
  const BorrowingCapacityHeroCard({
    super.key,
    required this.eligibility,
    required this.onRequestLoan,
    this.onViewPassport,
  });

  final LoanEligibilityEntity? eligibility;
  final VoidCallback onRequestLoan;
  final VoidCallback? onViewPassport;

  @override
  Widget build(BuildContext context) {
    final capacity = eligibility?.maxBorrowingCapacity ?? 0;
    final isEligible = eligibility?.isEligible ?? false;
    final score = eligibility?.currentScore ?? 0;
    final grade = eligibility?.grade ?? 'C';

    return Container(
      key: const ValueKey('borrowing_capacity_hero_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E5275)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/branding/logo_symbol.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'FACILITATION AU CRÉDIT',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.accentSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isEligible
                      ? AppColors.success.withValues(alpha: 0.25)
                      : AppColors.warning.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEligible ? AppColors.success : AppColors.warning,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEligible ? Icons.verified : Icons.info_outline,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEligible
                          ? 'Score $score/100 (Grade $grade)'
                          : 'À consolider',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Capacité d\'emprunt certifiée Tekki',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEligible
                ? CurrencyFormatter.format(capacity)
                : 'En cours d\'analyse',
            key: const ValueKey('borrowing_capacity_amount_text'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eligibility?.recommendationMessage ??
                'Clôturez vos journées pour faire certifier vos flux et débloquer vos prêts partenaires.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('hero_request_loan_button'),
                  onPressed: onRequestLoan,
                  icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                  label: const Text(
                    'Demander un prêt',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              if (onViewPassport != null) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  key: const ValueKey('hero_view_passport_button'),
                  tooltip: 'Consulter mon passeport',
                  onPressed: onViewPassport,
                  icon: const Icon(Icons.badge_outlined, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
