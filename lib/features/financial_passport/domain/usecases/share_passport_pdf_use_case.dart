import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/share_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import 'package:tekki/features/financial_passport/domain/services/pdf_generator_service.dart';

/// Cas d'utilisation coordonnant la génération locale de l'attestation PDF
/// certifiée et son partage via la feuille de partage native (WhatsApp, etc.).
class SharePassportPdfUseCase {
  const SharePassportPdfUseCase({
    required this.pdfGeneratorService,
    required this.shareService,
  });

  final IPdfGeneratorService pdfGeneratorService;
  final IShareService shareService;

  Future<Result<bool, Failure>> call({
    required SignedPassportPayloadEntity payload,
    String? shopName,
    DateTime? emissionDate,
  }) async {
    try {
      final pdfBytes = await pdfGeneratorService.generatePassportPdf(
        payload: payload,
        shopName: shopName,
        emissionDate: emissionDate,
      );

      final fileName = 'attestation_tekki_${payload.shopId}.pdf';
      final subject =
          'Attestation Passeport Financier Tekki - ${shopName ?? payload.shopId}';
      final text =
          'Bonjour, voici mon attestation officielle de Passeport Financier Tekki '
          '(Score : ${payload.passport.overallScore}/100, ${payload.passport.totalClosures} clôtures certifiées). '
          'Ce document est infalsifiable et vérifiable hors-ligne d\'appareil à appareil par QR Code et code PIN.';

      final shared = await shareService.sharePdfFile(
        bytes: pdfBytes,
        fileName: fileName,
        subject: subject,
        text: text,
      );

      if (!shared) {
        return Result.failure<bool, Failure>(
          const ServiceFailure(
            message:
                'Impossible de déclencher la feuille de partage de l\'appareil.',
          ),
        );
      }

      return Result.success<bool, Failure>(true);
    } catch (e) {
      return Result.failure<bool, Failure>(
        ServiceFailure(
          message:
              'Erreur lors de la génération ou du partage de l\'attestation : $e',
        ),
      );
    }
  }
}
