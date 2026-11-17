import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';

/// Contrat du service de signature cryptographique asymétrique Ed25519
/// et dérivation de code PIN dynamique anti-rejeu.
abstract interface class ICryptoSignatureService {
  /// Obtient ou génère de façon déterministe la clé publique Ed25519 (32 octets) de la boutique.
  Future<Uint8List> getOrCreatePublicKey({String? shopId});

  /// Signe une charge utile binaire avec la clé privée Ed25519 de la boutique (signature 64 octets).
  Future<Uint8List> sign(List<int> message, {String? shopId});

  /// Vérifie la validité mathématique d'une signature Ed25519 (64 octets)
  /// pour un message et une clé publique (32 octets) donnés.
  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  });

  /// Dérive un code PIN visuel à 4 chiffres (ex: "4821") par HMAC-SHA256(Signature, Timestamp_Minute).
  ///
  /// Le PIN est stable pendant la même minute UTC et renouvelé à la minute suivante.
  Future<String> deriveVisualPin({
    required List<int> signature,
    DateTime? calculatedAt,
    int? timestampSeconds,
  });
}

/// Implémentation de référence de [ICryptoSignatureService] utilisant
/// `package:cryptography` et [ISecureKeyStorage].
class CryptoSignatureService implements ICryptoSignatureService {
  CryptoSignatureService({
    required this.secureKeyStorage,
    Ed25519? algorithm,
    Hmac? hmacSha256,
  }) : _algorithm = algorithm ?? Ed25519(),
       _hmacSha256 = hmacSha256 ?? Hmac.sha256();

  final ISecureKeyStorage secureKeyStorage;
  final Ed25519 _algorithm;
  final Hmac _hmacSha256;

  String _privateKeyStorageKey(String? shopId) =>
      'tekki_ed25519_pk_${shopId != null && shopId.trim().isNotEmpty ? shopId.trim() : "default"}';

  /// Récupère ou génère la paire de clés Ed25519 dans le stockage sécurisé.
  Future<SimpleKeyPair> _getKeyPair({String? shopId}) async {
    final storageKey = _privateKeyStorageKey(shopId);
    final storedKey = await secureKeyStorage.read(key: storageKey);

    if (storedKey != null && storedKey.isNotEmpty) {
      try {
        final privateKeyBytes = base64Decode(storedKey);
        if (privateKeyBytes.length == 32) {
          return await _algorithm.newKeyPairFromSeed(privateKeyBytes);
        }
      } catch (_) {
        // En cas de corruption des données de stockage, régénération
      }
    }

    // Nouvelle génération
    final newKeyPair = await _algorithm.newKeyPair();
    final privBytes = await newKeyPair.extractPrivateKeyBytes();
    await secureKeyStorage.write(
      key: storageKey,
      value: base64Encode(privBytes),
    );
    return newKeyPair;
  }

  @override
  Future<Uint8List> getOrCreatePublicKey({String? shopId}) async {
    final keyPair = await _getKeyPair(shopId: shopId);
    final publicKey = await keyPair.extractPublicKey();
    return Uint8List.fromList(publicKey.bytes);
  }

  @override
  Future<Uint8List> sign(List<int> message, {String? shopId}) async {
    final keyPair = await _getKeyPair(shopId: shopId);
    final signature = await _algorithm.sign(message, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  @override
  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  }) async {
    try {
      if (publicKey.length != 32 || signature.length != 64) {
        return false;
      }
      final pubKeyObj = SimplePublicKey(publicKey, type: KeyPairType.ed25519);
      final sigObj = Signature(signature, publicKey: pubKeyObj);
      return await _algorithm.verify(message, signature: sigObj);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> deriveVisualPin({
    required List<int> signature,
    DateTime? calculatedAt,
    int? timestampSeconds,
  }) async {
    if (signature.length != 64) {
      throw ArgumentError.value(
        signature.length,
        'signature',
        'deriveVisualPin requires exactly 64 bytes signature (got ${signature.length})',
      );
    }
    final seconds =
        timestampSeconds ??
        ((calculatedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/
            1000);
    final timestampMinute = (seconds / 60).floor();
    final data = utf8.encode(timestampMinute.toString());

    final mac = await _hmacSha256.calculateMac(
      data,
      secretKey: SecretKey(signature),
    );
    final bytes = mac.bytes;

    final pinNumber =
        ByteData.sublistView(
          Uint8List.fromList(bytes),
        ).getUint32(0, Endian.big) %
        10000;
    return pinNumber.toString().padLeft(4, '0');
  }
}
