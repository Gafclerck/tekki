import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';

/// Entité immuable de domaine représentant le Passeport Financier signé numériquement.
///
/// Contient le passeport financier complet, la signature binaire Ed25519 (64 octets),
/// la clé publique de la boutique (32 octets), la charge utile compacte encodée en Base45,
/// et le code PIN visuel dynamique à 4 chiffres anti-rejeu.
class SignedPassportPayloadEntity extends Equatable {
  SignedPassportPayloadEntity({
    required this.passport,
    required this.shopId,
    required List<int> signature,
    required List<int> publicKey,
    required this.base45Payload,
    required this.visualPin,
    this.isValid = true,
  }) : signature = Uint8List.fromList(signature),
       publicKey = Uint8List.fromList(publicKey) {
    if (shopId.trim().isEmpty) {
      throw ArgumentError('shopId cannot be empty');
    }
    if (this.signature.length != 64) {
      throw ArgumentError(
        'signature must be exactly 64 bytes (got ${this.signature.length})',
      );
    }
    if (this.publicKey.length != 32) {
      throw ArgumentError(
        'publicKey must be exactly 32 bytes (got ${this.publicKey.length})',
      );
    }
    if (base45Payload.trim().isEmpty) {
      throw ArgumentError('base45Payload cannot be empty');
    }
    if (visualPin.length != 4 || int.tryParse(visualPin) == null) {
      throw ArgumentError('visualPin must be exactly 4 digits');
    }
  }

  const SignedPassportPayloadEntity.raw({
    required this.passport,
    required this.shopId,
    required this.signature,
    required this.publicKey,
    required this.base45Payload,
    required this.visualPin,
    this.isValid = true,
  }) : assert(shopId != '', 'shopId cannot be empty'),
       assert(signature.length == 64, 'signature must be exactly 64 bytes'),
       assert(publicKey.length == 32, 'publicKey must be exactly 32 bytes'),
       assert(base45Payload != '', 'base45Payload cannot be empty'),
       assert(visualPin.length == 4, 'visualPin must be exactly 4 digits');

  /// Entité complète du passeport financier (score global, piliers, éligibilité).
  final FinancialPassportEntity passport;

  /// Identifiant unique de la boutique émettrice.
  final String shopId;

  /// Signature cryptographique Ed25519 (64 octets).
  final Uint8List signature;

  /// Clé publique Ed25519 de la boutique (32 octets).
  final Uint8List publicKey;

  /// Charge utile binaire CBOR encodée en Base45 (RFC 9285).
  final String base45Payload;

  /// Code PIN visuel à 4 chiffres anti-rejeu (HMAC-SHA256).
  final String visualPin;

  /// Indicateur de validité de la signature cryptographique.
  final bool isValid;

  SignedPassportPayloadEntity copyWith({
    FinancialPassportEntity? passport,
    String? shopId,
    Uint8List? signature,
    Uint8List? publicKey,
    String? base45Payload,
    String? visualPin,
    bool? isValid,
  }) {
    return SignedPassportPayloadEntity(
      passport: passport ?? this.passport,
      shopId: shopId ?? this.shopId,
      signature: signature ?? this.signature,
      publicKey: publicKey ?? this.publicKey,
      base45Payload: base45Payload ?? this.base45Payload,
      visualPin: visualPin ?? this.visualPin,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
    passport,
    shopId,
    signature,
    publicKey,
    base45Payload,
    visualPin,
    isValid,
  ];
}
