import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';

class PassportEncouragementView extends StatelessWidget {
  const PassportEncouragementView({
    super.key,
    required this.passport,
    required this.closuresNeeded,
    this.onActionPressed,
  });

  final FinancialPassportEntity passport;
  final int closuresNeeded;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final progress = (passport.totalClosures / 7.0).clamp(0.0, 1.0);

    return Container(
      key: const ValueKey('passport_encouragement_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte principale d'encouragement
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.tertiary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.tertiary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.accent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Débloquez votre Passeport',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Encore $closuresNeeded ${closuresNeeded > 1 ? 'clôtures' : 'clôture'} pour générer votre premier Passeport Financier officiel.',
                  key: const ValueKey('encouragement_message_text'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Jauge de progression
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '${passport.totalClosures} / 7 clôtures',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    key: const ValueKey('encouragement_progress_bar'),
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Explication pédagogique des 4 piliers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Comment fonctionne votre score ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildGuideItem(
                  icon: Icons.event_available,
                  title: 'Régularité des clôtures (35 %)',
                  subtitle:
                      'Clôturez votre caisse chaque soir après vos ventes.',
                ),
                const SizedBox(height: 8),
                _buildGuideItem(
                  icon: Icons.payments_outlined,
                  title: 'Vélocité Karné Bor (40 %)',
                  subtitle: 'Faites régler vos dettes clients à bonne date.',
                ),
                const SizedBox(height: 8),
                _buildGuideItem(
                  icon: Icons.location_on_outlined,
                  title: 'Stabilité géographique (15 %)',
                  subtitle:
                      'Clôturez depuis l\'emplacement habituel de votre boutique.',
                ),
                const SizedBox(height: 8),
                _buildGuideItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Discipline d\'encaisse (10 %)',
                  subtitle: 'Conservez une trésorerie stable et mesurée.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
