import 'dart:typed_data';

import 'package:tekki/core/crypto/base45.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/data/models/cbor_passport_payload.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';

/// Cas d'utilisation de vérification autonome d'appareil à appareil (D2D) sans accès Internet.
///
/// Décode la chaîne Base45, désérialise le format CBOR binaire compact, et valide mathématiquement
/// la signature Ed25519 avec la clé publique embarquée ou attendue.
class VerifyPassportPayloadUseCase {
  const VerifyPassportPayloadUseCase({required this.cryptoSignatureService});

  final ICryptoSignatureService cryptoSignatureService;

  Future<Result<SignedPassportPayloadEntity, Failure>> call(
    String base45Payload, {
    List<int>? expectedPublicKey,
    String? visualPinToVerify,
    DateTime? verificationTime,
  }) async {
    const defaultFailure = CryptoFailure(
      message: 'Signature invalide ou charge utile corrompue',
    );

    if (base45Payload.trim().isEmpty) {
      return const Error(defaultFailure);
    }

    try {
      // 1. Décodage Base45
      final Uint8List cborBytes;
      try {
        cborBytes = Base45.decode(base45Payload);
      } catch (_) {
        return const Error(defaultFailure);
      }

      // 2. Désérialisation binaire CBOR
      final CborPassportPayload payload;
      try {
        payload = CborPassportPayload.fromCbor(cborBytes);
      } catch (_) {
        return const Error(defaultFailure);
      }

      if (payload.signature == null || payload.signature!.length != 64) {
        return const Error(defaultFailure);
      }

      if (payload.publicKey.length != 32) {
        return const Error(defaultFailure);
      }

      // 3. Validation de la clé publique si spécifiée
      if (expectedPublicKey != null) {
        if (expectedPublicKey.length != 32) {
          return const Error(defaultFailure);
        }
        for (int i = 0; i < 32; i++) {
          if (payload.publicKey[i] != expectedPublicKey[i]) {
            return const Error(defaultFailure);
          }
        }
      }

      // 4. Extraction de la charge canonique signable (champs 1 à 11)
      final signableBytes = payload.toSignableCbor();

      // 5. Validation mathématique de la signature asymétrique Ed25519
      final isValid = await cryptoSignatureService.verify(
        signableBytes,
        signature: payload.signature!,
        publicKey: payload.publicKey,
      );

      if (!isValid) {
        return const Error(defaultFailure);
      }

      // 6. Validation du code PIN visuel anti-rejeu (tolérance de dérive de 1 minute)
      if (visualPinToVerify != null) {
        final effectiveTime = (verificationTime ?? DateTime.now()).toUtc();
        final currentPin = await cryptoSignatureService.deriveVisualPin(
          signature: payload.signature!,
          calculatedAt: effectiveTime,
        );
        final driftPin = await cryptoSignatureService.deriveVisualPin(
          signature: payload.signature!,
          calculatedAt: effectiveTime.subtract(const Duration(minutes: 1)),
        );

        if (visualPinToVerify != currentPin && visualPinToVerify != driftPin) {
          return const Error(
            CryptoFailure(message: 'Code PIN visuel invalide ou expiré'),
          );
        }
      }

      final passportEntity = payload.toEntity();
      final visualPin =
          visualPinToVerify ??
          await cryptoSignatureService.deriveVisualPin(
            signature: payload.signature!,
            calculatedAt: verificationTime ?? passportEntity.calculatedAt,
          );

      final signedEntity = SignedPassportPayloadEntity(
        passport: passportEntity,
        shopId: payload.shopId,
        signature: payload.signature!,
        publicKey: payload.publicKey,
        base45Payload: base45Payload,
        visualPin: visualPin,
        isValid: true,
      );

      return Success(signedEntity);
    } catch (_) {
      return const Error(defaultFailure);
    }
  }
}
