import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  group('SignedPassportPayloadEntity Unit Tests', () {
    final passport = createTestFinancialPassport();
    final validSignature = Uint8List(64)..fillRange(0, 64, 1);
    final validPubKey = Uint8List(32)..fillRange(0, 32, 2);

    test('Nominal instantiation succeeds with valid 4-digit PIN', () {
      final entity = SignedPassportPayloadEntity(
        passport: passport,
        shopId: 'shop-1',
        signature: validSignature,
        publicKey: validPubKey,
        base45Payload: 'BASE45',
        visualPin: '1234',
      );

      expect(entity.visualPin, equals('1234'));
      expect(entity.isValid, isTrue);
    });

    test('Rejects visualPin with non-digit characters', () {
      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: 'shop-1',
          signature: validSignature,
          publicKey: validPubKey,
          base45Payload: 'BASE45',
          visualPin: '12a4',
        ),
        throwsArgumentError,
      );
    });

    test('Rejects visualPin with length != 4', () {
      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: 'shop-1',
          signature: validSignature,
          publicKey: validPubKey,
          base45Payload: 'BASE45',
          visualPin: '123',
        ),
        throwsArgumentError,
      );

      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: 'shop-1',
          signature: validSignature,
          publicKey: validPubKey,
          base45Payload: 'BASE45',
          visualPin: '12345',
        ),
        throwsArgumentError,
      );
    });

    test('Rejects empty shopId', () {
      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: '   ',
          signature: validSignature,
          publicKey: validPubKey,
          base45Payload: 'BASE45',
          visualPin: '1234',
        ),
        throwsArgumentError,
      );
    });

    test('Rejects invalid signature or publicKey lengths', () {
      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: 'shop-1',
          signature: Uint8List(63),
          publicKey: validPubKey,
          base45Payload: 'BASE45',
          visualPin: '1234',
        ),
        throwsArgumentError,
      );

      expect(
        () => SignedPassportPayloadEntity(
          passport: passport,
          shopId: 'shop-1',
          signature: validSignature,
          publicKey: Uint8List(31),
          base45Payload: 'BASE45',
          visualPin: '1234',
        ),
        throwsArgumentError,
      );
    });

    test('Raw constructor creates entity and copyWith preserves fields', () {
      final raw = SignedPassportPayloadEntity.raw(
        passport: passport,
        shopId: 'shop-1',
        signature: validSignature,
        publicKey: validPubKey,
        base45Payload: 'BASE45',
        visualPin: '5678',
      );

      expect(raw.visualPin, equals('5678'));

      final copied = raw.copyWith(visualPin: '9999');
      expect(copied.visualPin, equals('9999'));
      expect(copied.shopId, equals('shop-1'));
    });
  });
}
