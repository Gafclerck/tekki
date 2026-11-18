import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';

class PartnerCard extends StatelessWidget {
  const PartnerCard({
    super.key,
    required this.partner,
    required this.isEligible,
    required this.onApply,
  });

  final FinancialPartnerEntity partner;
  final bool isEligible;
  final VoidCallback onApply;

  Widget _buildPartnerAvatar(FinancialPartnerEntity partner) {
    final (Color bg, Color fg, String initials) = switch (partner.id) {
      'baobab_sn' => (const Color(0xFFFFF0EB), const Color(0xFFE84E1B), 'BB'),
      'cofina_sn' => (const Color(0xFFFEECEB), const Color(0xFFA31920), 'CF'),
      'pamecas_sn' => (const Color(0xFFEBF3FB), const Color(0xFF004B87), 'PM'),
      'ecobank_sn' => (const Color(0xFFE6F5F8), const Color(0xFF005A70), 'ECO'),
      _ => (
        AppColors.background,
        AppColors.primary,
        partner.name.substring(0, 2).toUpperCase(),
      ),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: fg.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: initials.length > 2 ? 11 : 14,
            fontWeight: FontWeight.w900,
            color: fg,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('partner_card_${partner.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.tertiary.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPartnerAvatar(partner),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            partner.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (partner.badgeLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              partner.badgeLabel!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${partner.typeDisplayName} • Réponse sous ${partner.processingTimeDays}j',
                      style: const TextStyle(
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
          const SizedBox(height: 10),
          Text(
            partner.tagline,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    label: 'Montant max',
                    value: CurrencyFormatter.format(partner.maxAmount),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Taux mensuel',
                    value: '~${partner.interestRateMonthly}%',
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Durée',
                    value:
                        '${partner.minDurationMonths}-${partner.maxDurationMonths} m',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isEligible
                          ? Icons.check_circle_rounded
                          : Icons.info_outline,
                      size: 15,
                      color: isEligible ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isEligible
                            ? 'Éligible immédiatement'
                            : 'Score min. : ${partner.requiredMinScore}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isEligible
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: ValueKey('partner_apply_button_${partner.id}'),
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEligible
                      ? AppColors.primary
                      : AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(90, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Postuler',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
