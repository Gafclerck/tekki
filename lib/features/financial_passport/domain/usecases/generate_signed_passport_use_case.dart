import 'package:tekki/core/crypto/base45.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/data/models/cbor_passport_payload.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';

/// Cas d'utilisation Command orchestrant la validation d'éligibilité, la sérialisation CBOR,
/// la signature numérique Ed25519 (64 octets), l'encodage Base45 et la dérivation du PIN anti-rejeu.
class GenerateSignedPassportUseCase {
  const GenerateSignedPassportUseCase({required this.cryptoSignatureService});

  final ICryptoSignatureService cryptoSignatureService;

  Future<Result<SignedPassportPayloadEntity, Failure>> call({
    required FinancialPassportEntity passport,
    required String shopId,
    DateTime? pinTimestamp,
  }) async {
    // Règle d'éligibilité stricte : minimum 7 clôtures
    if (!passport.isEligible || passport.totalClosures < 7) {
      return const Error(
        ValidationFailure(
          message: 'Passeport non éligible à la signature officielle',
        ),
      );
    }

    if (shopId.trim().isEmpty) {
      return const Error(
        ValidationFailure(message: 'Identifiant de boutique invalide'),
      );
    }

    try {
      // 1. Récupération ou initialisation de la clé publique Ed25519 de la boutique
      final publicKey = await cryptoSignatureService.getOrCreatePublicKey(
        shopId: shopId,
      );

      // 2. Assemblage du CBOR canonique des métriques (champs 1 à 11)
      final cborPayload = CborPassportPayload.fromPassport(
        passport: passport,
        shopId: shopId,
        publicKey: publicKey,
      );
      final signableBytes = cborPayload.toSignableCbor();

      // 3. Signature numérique Ed25519 (64 octets)
      final signature = await cryptoSignatureService.sign(
        signableBytes,
        shopId: shopId,
      );

      // 4. Assemblage du CBOR complet incluant la signature (champs 1 à 12)
      final fullCborPayload = CborPassportPayload.fromPassport(
        passport: passport,
        shopId: shopId,
        publicKey: publicKey,
        signature: signature,
      );
      final fullBytes = fullCborPayload.toFullCbor();

      // 5. Encodage Base45 (RFC 9285)
      final base45Payload = Base45.encode(fullBytes);

      // 6. Dérivation du code PIN visuel dynamique à 4 chiffres (HMAC-SHA256)
      final visualPin = await cryptoSignatureService.deriveVisualPin(
        signature: signature,
        calculatedAt: pinTimestamp ?? DateTime.now(),
      );

      final signedEntity = SignedPassportPayloadEntity(
        passport: passport,
        shopId: shopId,
        signature: signature,
        publicKey: publicKey,
        base45Payload: base45Payload,
        visualPin: visualPin,
        isValid: true,
      );

      return Success(signedEntity);
    } catch (e) {
      return Error(CryptoFailure(message: 'Erreur lors de la signature: $e'));
    }
  }
}
