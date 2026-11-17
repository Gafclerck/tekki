import 'dart:typed_data';

import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';

/// Contrat du domaine pour la génération du document officiel PDF d'attestation
/// de Passeport Financier Tekki.
///
/// Pur Dart : Zéro import Flutter ou Drift.
abstract class IPdfGeneratorService {
  /// Génère le document PDF vectoriel de l'attestation officielle de Passeport Financier.
  ///
  /// Prend en entrée la charge signée [payload], le nom de la boutique optionnel [shopName]
  /// et la date d'émission [emissionDate].
  /// Retourne les octets binaires [Uint8List] du document PDF vectoriel.
  Future<Uint8List> generatePassportPdf({
    required SignedPassportPayloadEntity payload,
    String? shopName,
    DateTime? emissionDate,
  });
}
