import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';

class InMemorySecureKeyStorage implements ISecureKeyStorage {
  final Map<String, String> _store = {};

  @override
  Future<bool> containsKey({required String key}) async =>
      _store.containsKey(key);

  @override
  Future<void> delete({required String key}) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }
}

void main() {
  group('CryptoSignatureService Unit Tests', () {
    late InMemorySecureKeyStorage secureStorage;
    late CryptoSignatureService cryptoService;

    setUp(() {
      secureStorage = InMemorySecureKeyStorage();
      cryptoService = CryptoSignatureService(secureKeyStorage: secureStorage);
    });

    test(
      'Initial generation: creates Ed25519 key pair, persists in secure storage, returns 32-byte public key',
      () async {
        final publicKey = await cryptoService.getOrCreatePublicKey(
          shopId: 'shop-alpha',
        );

        expect(publicKey.length, equals(32));
        final storedKey = await secureStorage.read(
          key: 'tekki_ed25519_pk_shop-alpha',
        );
        expect(storedKey, isNotNull);
        expect(base64Decode(storedKey!).length, equals(32));
      },
    );

    test(
      'Determinism: retrieves existing key pair without regenerating new keys',
      () async {
        final pubKey1 = await cryptoService.getOrCreatePublicKey(
          shopId: 'shop-beta',
        );
        final storedAfterFirst = await secureStorage.read(
          key: 'tekki_ed25519_pk_shop-beta',
        );

        final pubKey2 = await cryptoService.getOrCreatePublicKey(
          shopId: 'shop-beta',
        );
        final storedAfterSecond = await secureStorage.read(
          key: 'tekki_ed25519_pk_shop-beta',
        );

        expect(pubKey1, equals(pubKey2));
        expect(storedAfterFirst, equals(storedAfterSecond));
      },
    );

    test(
      'Gracefully recovers and regenerates key if stored value is corrupted',
      () async {
        await secureStorage.write(
          key: 'tekki_ed25519_pk_shop-corrupted',
          value: 'INVALID_BASE_64_GARBAGE',
        );

        final pubKey = await cryptoService.getOrCreatePublicKey(
          shopId: 'shop-corrupted',
        );
        expect(pubKey.length, equals(32));
        final recoveredStored = await secureStorage.read(
          key: 'tekki_ed25519_pk_shop-corrupted',
        );
        expect(base64Decode(recoveredStored!).length, equals(32));
      },
    );

    test(
      'Sign produces 64-byte signature and verify returns true for authentic message',
      () async {
        final pubKey = await cryptoService.getOrCreatePublicKey(
          shopId: 'shop-gamma',
        );
        final message = Uint8List.fromList(
          utf8.encode('Tekki Certified Passport 2026'),
        );

        final signature = await cryptoService.sign(
          message,
          shopId: 'shop-gamma',
        );
        expect(signature.length, equals(64));

        final isValid = await cryptoService.verify(
          message,
          signature: signature,
          publicKey: pubKey,
        );
        expect(isValid, isTrue);
      },
    );

    test('Verify rejects altered message (tampering detection)', () async {
      final pubKey = await cryptoService.getOrCreatePublicKey(
        shopId: 'shop-gamma',
      );
      final originalMessage = Uint8List.fromList(
        utf8.encode('Original message'),
      );
      final tamperedMessage = Uint8List.fromList(
        utf8.encode('Tampered message'),
      );

      final signature = await cryptoService.sign(
        originalMessage,
        shopId: 'shop-gamma',
      );

      final isValid = await cryptoService.verify(
        tamperedMessage,
        signature: signature,
        publicKey: pubKey,
      );
      expect(isValid, isFalse);
    });

    test('Verify rejects corrupted signature (byte alteration)', () async {
      final pubKey = await cryptoService.getOrCreatePublicKey(
        shopId: 'shop-gamma',
      );
      final message = Uint8List.fromList(utf8.encode('Original message'));

      final signature = await cryptoService.sign(message, shopId: 'shop-gamma');
      final corruptedSignature = Uint8List.fromList(signature);
      corruptedSignature[0] ^= 0xFF; // Flip first byte

      final isValid = await cryptoService.verify(
        message,
        signature: corruptedSignature,
        publicKey: pubKey,
      );
      expect(isValid, isFalse);
    });

    test('Verify rejects signature with different public key', () async {
      final message = Uint8List.fromList(utf8.encode('Original message'));

      final signature1 = await cryptoService.sign(message, shopId: 'shop-1');
      final pubKey2 = await cryptoService.getOrCreatePublicKey(
        shopId: 'shop-2',
      );

      final isValid = await cryptoService.verify(
        message,
        signature: signature1,
        publicKey: pubKey2,
      );
      expect(isValid, isFalse);
    });

    test('Verify safely handles malformed lengths without throwing', () async {
      final message = Uint8List.fromList([1, 2, 3]);

      expect(
        await cryptoService.verify(
          message,
          signature: Uint8List(10), // Not 64
          publicKey: Uint8List(32),
        ),
        isFalse,
      );

      expect(
        await cryptoService.verify(
          message,
          signature: Uint8List(64),
          publicKey: Uint8List(20), // Not 32
        ),
        isFalse,
      );
    });

    test(
      'deriveVisualPin: deterministically generates 4-digit PIN stable during same minute',
      () async {
        final signature = Uint8List(64)..fillRange(0, 64, 42);
        final t1 = DateTime.utc(2026, 11, 17, 14, 30, 10);
        final t2 = DateTime.utc(2026, 11, 17, 14, 30, 50);

        final pin1 = await cryptoService.deriveVisualPin(
          signature: signature,
          calculatedAt: t1,
        );
        final pin2 = await cryptoService.deriveVisualPin(
          signature: signature,
          calculatedAt: t2,
        );

        expect(pin1, equals(pin2));
        expect(RegExp(r'^\d{4}$').hasMatch(pin1), isTrue);
      },
    );

    test('deriveVisualPin: renovates PIN at subsequent minute', () async {
      final signature = Uint8List(64)..fillRange(0, 64, 42);
      final t1 = DateTime.utc(2026, 11, 17, 14, 30, 50);
      final tNextMinute = DateTime.utc(2026, 11, 17, 14, 31, 10);

      final pin1 = await cryptoService.deriveVisualPin(
        signature: signature,
        calculatedAt: t1,
      );
      final pinNext = await cryptoService.deriveVisualPin(
        signature: signature,
        calculatedAt: tNextMinute,
      );

      expect(RegExp(r'^\d{4}$').hasMatch(pinNext), isTrue);
      expect(pin1, isNot(equals(pinNext)));
    });

    test('deriveVisualPin: supports explicit timestampSeconds', () async {
      final signature = Uint8List(64)..fillRange(0, 64, 99);
      const epochSeconds = 1770000000;

      final pin = await cryptoService.deriveVisualPin(
        signature: signature,
        timestampSeconds: epochSeconds,
      );

      expect(RegExp(r'^\d{4}$').hasMatch(pin), isTrue);
    });

    test(
      'deriveVisualPin rejects signature with length != 64 with ArgumentError',
      () async {
        expect(
          () => cryptoService.deriveVisualPin(signature: Uint8List(32)),
          throwsArgumentError,
        );
        expect(
          () => cryptoService.deriveVisualPin(signature: Uint8List(65)),
          throwsArgumentError,
        );
      },
    );
  });
}
