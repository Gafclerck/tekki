import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:equatable/equatable.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';

/// Modèle DTO pour la sérialisation / désérialisation binaire compacte CBOR (RFC 8949)
/// des métriques du Passeport Financier Tekki.
///
/// Clés entières CBOR courtes pour compacité QR code :
/// - Clé 1 : Version du schéma (entier 1)
/// - Clé 2 : Identifiant de boutique `shopId` (texte UTF-8)
/// - Clé 3 : Score global sur 100 (entier)
/// - Clé 4 : Total des clôtures sur 30 jours (entier)
/// - Clé 5 : Série de clôtures consécutives `streak` (entier)
/// - Clé 6 : Score pilier Karné Bor (entier)
/// - Clé 7 : Score pilier Clôtures (entier)
/// - Clé 8 : Score pilier GPS (entier)
/// - Clé 9 : Score pilier Encaisse (entier)
/// - Clé 10 : Horodatage du calcul `calculatedAt` (entier secondes epoch UTC)
/// - Clé 11 : Clé publique Ed25519 de la boutique (octets Uint8List, 32 octets)
/// - Clé 12 : Signature numérique Ed25519 (octets Uint8List, 64 octets)
class CborPassportPayload extends Equatable {
  CborPassportPayload({
    this.version = 1,
    required this.shopId,
    required this.overallScore,
    required this.totalClosures,
    required this.streak,
    required this.debtScore,
    required this.closureScore,
    required this.gpsScore,
    required this.cashScore,
    required this.calculatedAtSeconds,
    required List<int> publicKey,
    List<int>? signature,
  }) : publicKey = Uint8List.fromList(publicKey),
       signature = signature != null ? Uint8List.fromList(signature) : null;

  factory CborPassportPayload.fromPassport({
    required FinancialPassportEntity passport,
    required String shopId,
    required List<int> publicKey,
    List<int>? signature,
    int version = 1,
  }) {
    return CborPassportPayload(
      version: version,
      shopId: shopId,
      overallScore: passport.overallScore,
      totalClosures: passport.totalClosures,
      streak: passport.streak,
      debtScore: passport.breakdown.debtScore,
      closureScore: passport.breakdown.closureScore,
      gpsScore: passport.breakdown.gpsScore,
      cashScore: passport.breakdown.cashScore,
      calculatedAtSeconds:
          passport.calculatedAt.toUtc().millisecondsSinceEpoch ~/ 1000,
      publicKey: publicKey,
      signature: signature,
    );
  }

  factory CborPassportPayload.fromCbor(List<int> bytes) {
    try {
      final decoded = cbor.decode(bytes);
      if (decoded is! CborMap) {
        throw const FormatException(
          'Le contenu CBOR racine doit être une CborMap',
        );
      }

      CborValue? getVal(int key) {
        for (final entry in decoded.entries) {
          final k = entry.key;
          if (k is CborSmallInt && k.value == key) return entry.value;
          if (k is CborInt && k.toInt() == key) return entry.value;
        }
        return null;
      }

      int asInt(CborValue? val, String field) {
        if (val is CborSmallInt) return val.value;
        if (val is CborInt) return val.toInt();
        throw FormatException('Champ $field manquant ou invalide');
      }

      String asString(CborValue? val, String field) {
        if (val is CborString) return val.toString();
        throw FormatException('Champ $field manquant ou invalide');
      }

      Uint8List asBytes(CborValue? val, String field) {
        if (val is CborBytes) return Uint8List.fromList(val.bytes);
        throw FormatException('Champ $field manquant ou invalide');
      }

      final version = asInt(getVal(1), 'version (clé 1)');
      if (version != 1) {
        throw FormatException(
          'Version de schéma non supportée: $version (attendu: 1)',
        );
      }
      final shopId = asString(getVal(2), 'shopId (clé 2)');
      final overallScore = asInt(getVal(3), 'overallScore (clé 3)');
      final totalClosures = asInt(getVal(4), 'totalClosures (clé 4)');
      final streak = asInt(getVal(5), 'streak (clé 5)');
      final debtScore = asInt(getVal(6), 'debtScore (clé 6)');
      final closureScore = asInt(getVal(7), 'closureScore (clé 7)');
      final gpsScore = asInt(getVal(8), 'gpsScore (clé 8)');
      final cashScore = asInt(getVal(9), 'cashScore (clé 9)');
      final calculatedAtSeconds = asInt(
        getVal(10),
        'calculatedAtSeconds (clé 10)',
      );
      final publicKey = asBytes(getVal(11), 'publicKey (clé 11)');

      final sigVal = getVal(12);
      final signature = sigVal != null
          ? asBytes(sigVal, 'signature (clé 12)')
          : null;

      return CborPassportPayload(
        version: version,
        shopId: shopId,
        overallScore: overallScore,
        totalClosures: totalClosures,
        streak: streak,
        debtScore: debtScore,
        closureScore: closureScore,
        gpsScore: gpsScore,
        cashScore: cashScore,
        calculatedAtSeconds: calculatedAtSeconds,
        publicKey: publicKey,
        signature: signature,
      );
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Erreur de désérialisation CBOR: $e');
    }
  }

  final int version;
  final String shopId;
  final int overallScore;
  final int totalClosures;
  final int streak;
  final int debtScore;
  final int closureScore;
  final int gpsScore;
  final int cashScore;
  final int calculatedAtSeconds;
  final Uint8List publicKey;
  final Uint8List? signature;

  /// Sérialise les champs 1 à 11 pour le calcul de la signature Ed25519 canonique.
  Uint8List toSignableCbor() {
    final map = CborMap({
      const CborSmallInt(1): CborSmallInt(version),
      const CborSmallInt(2): CborString(shopId),
      const CborSmallInt(3): CborSmallInt(overallScore),
      const CborSmallInt(4): CborSmallInt(totalClosures),
      const CborSmallInt(5): CborSmallInt(streak),
      const CborSmallInt(6): CborSmallInt(debtScore),
      const CborSmallInt(7): CborSmallInt(closureScore),
      const CborSmallInt(8): CborSmallInt(gpsScore),
      const CborSmallInt(9): CborSmallInt(cashScore),
      const CborSmallInt(10): CborSmallInt(calculatedAtSeconds),
      const CborSmallInt(11): CborBytes(publicKey),
    });
    return Uint8List.fromList(cbor.encode(map));
  }

  /// Sérialise la charge utile complète (champs 1 à 12) incluant la signature.
  Uint8List toFullCbor() {
    if (signature == null) {
      throw StateError('Impossible de sérialiser en full CBOR sans signature');
    }
    final map = CborMap({
      const CborSmallInt(1): CborSmallInt(version),
      const CborSmallInt(2): CborString(shopId),
      const CborSmallInt(3): CborSmallInt(overallScore),
      const CborSmallInt(4): CborSmallInt(totalClosures),
      const CborSmallInt(5): CborSmallInt(streak),
      const CborSmallInt(6): CborSmallInt(debtScore),
      const CborSmallInt(7): CborSmallInt(closureScore),
      const CborSmallInt(8): CborSmallInt(gpsScore),
      const CborSmallInt(9): CborSmallInt(cashScore),
      const CborSmallInt(10): CborSmallInt(calculatedAtSeconds),
      const CborSmallInt(11): CborBytes(publicKey),
      const CborSmallInt(12): CborBytes(signature!),
    });
    return Uint8List.fromList(cbor.encode(map));
  }

  /// Convertit le DTO en entité métier [FinancialPassportEntity].
  FinancialPassportEntity toEntity() {
    final breakdown = ScoreBreakdownEntity(
      closureScore: closureScore,
      debtScore: debtScore,
      gpsScore: gpsScore,
      cashScore: cashScore,
    );
    final isEligible = totalClosures >= 7;
    final remainingClosures = isEligible ? 0 : 7 - totalClosures;
    final calculatedAt = DateTime.fromMillisecondsSinceEpoch(
      calculatedAtSeconds * 1000,
      isUtc: true,
    );

    return FinancialPassportEntity(
      overallScore: overallScore,
      breakdown: breakdown,
      isEligible: isEligible,
      totalClosures: totalClosures,
      remainingClosures: remainingClosures,
      streak: streak,
      calculatedAt: calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
    version,
    shopId,
    overallScore,
    totalClosures,
    streak,
    debtScore,
    closureScore,
    gpsScore,
    cashScore,
    calculatedAtSeconds,
    publicKey,
    signature,
  ];
}
