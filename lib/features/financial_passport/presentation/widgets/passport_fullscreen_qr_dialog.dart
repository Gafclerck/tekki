import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tekki/core/theme/app_colors.dart';

class PassportFullscreenQrDialog extends StatelessWidget {
  const PassportFullscreenQrDialog({
    super.key,
    required this.base45Payload,
    required this.visualPin,
    required this.secondsRemaining,
  });

  final String base45Payload;
  final String visualPin;
  final int secondsRemaining;

  static Future<void> show(
    BuildContext context, {
    required String base45Payload,
    required String visualPin,
    required int secondsRemaining,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PassportFullscreenQrDialog(
        base45Payload: base45Payload,
        visualPin: visualPin,
        secondsRemaining: secondsRemaining,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        key: const ValueKey('passport_fullscreen_qr_container'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Barre supérieure avec bouton fermer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_2, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Passeport Vérifiable D2D',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  key: const ValueKey('close_fullscreen_qr_button'),
                  icon: const Icon(Icons.close, color: AppColors.secondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fermer',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grand QR Code centré avec marge blanche de sécurité
            Container(
              key: const ValueKey('fullscreen_qr_image_container'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tertiary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                key: const ValueKey('fullscreen_qr_image'),
                data: base45Payload,
                version: QrVersions.auto,
                size: 260.0,
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
            const SizedBox(height: 18),

            // Badge PIN 4 chiffres agrandi
            Container(
              key: const ValueKey('fullscreen_pin_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.tertiary, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'CODE PIN DE CONFIRMATION VISUELLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visualPin,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Texte de décompte
            Text(
              'Renouvellement dans ${secondsRemaining}s',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
