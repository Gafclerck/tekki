import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_fullscreen_qr_dialog.dart';

class PassportQrCard extends StatelessWidget {
  const PassportQrCard({
    super.key,
    required this.base45Payload,
    required this.visualPin,
    required this.secondsRemaining,
    this.onTapQr,
  });

  final String base45Payload;
  final String visualPin;
  final int secondsRemaining;
  final VoidCallback? onTapQr;

  void _handleOpenFullscreen(BuildContext context) {
    if (onTapQr != null) {
      onTapQr!();
    } else {
      PassportFullscreenQrDialog.show(
        context,
        base45Payload: base45Payload,
        visualPin: visualPin,
        secondsRemaining: secondsRemaining,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (secondsRemaining / 60.0).clamp(0.0, 1.0);

    return Container(
      key: const ValueKey('passport-qr-card'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tertiary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Titre et bouton zoom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Attestation Cryptographique',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                key: const ValueKey('zoom_qr_button'),
                icon: const Icon(
                  Icons.fullscreen,
                  color: AppColors.secondary,
                  size: 24,
                ),
                onPressed: () => _handleOpenFullscreen(context),
                tooltip: 'Afficher en plein écran',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Zone QR Code tactile 150x150dp avec marge blanche de 8dp
          InkWell(
            key: const ValueKey('qr_code_tap_target'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleOpenFullscreen(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tertiary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: QrImageView(
                  key: const ValueKey('passport_qr_image'),
                  data: base45Payload,
                  version: QrVersions.auto,
                  size: 150.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Instruction d'interaction
          const Text(
            'Toucher le code pour agrandir en plein écran',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),

          // Badge PIN 4 chiffres sous le QR Code
          Container(
            key: const ValueKey('pin-code-badge'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.tertiary, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'PIN :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  visualPin,
                  key: const ValueKey('pin_code_digits'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Indicateur de renouvellement d'une minute
          Container(
            key: const ValueKey('pin_renewal_indicator'),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Validation anti-rejeu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '${secondsRemaining}s',
                      key: const ValueKey('pin_countdown_text'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    key: const ValueKey('pin_renewal_progress_bar'),
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
