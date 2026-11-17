import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('GenerateSignedPassportUseCase Unit Tests', () {
    late MockCryptoSignatureService mockCryptoService;
    late GenerateSignedPassportUseCase useCase;

    final testPubKey = Uint8List(32)..fillRange(0, 32, 1);
    final testSignature = Uint8List(64)..fillRange(0, 64, 2);

    setUp(() {
      mockCryptoService = MockCryptoSignatureService();
      useCase = GenerateSignedPassportUseCase(
        cryptoSignatureService: mockCryptoService,
      );

      when(
        () => mockCryptoService.getOrCreatePublicKey(
          shopId: any(named: 'shopId'),
        ),
      ).thenAnswer((_) async => testPubKey);

      when(
        () => mockCryptoService.sign(any(), shopId: any(named: 'shopId')),
      ).thenAnswer((_) async => testSignature);

      when(
        () => mockCryptoService.deriveVisualPin(
          signature: any(named: 'signature'),
          calculatedAt: any(named: 'calculatedAt'),
          timestampSeconds: any(named: 'timestampSeconds'),
        ),
      ).thenAnswer((_) async => '4821');
    });

    test(
      'Nominal case: signs eligible passport and returns complete SignedPassportPayloadEntity',
      () async {
        final passport = createTestFinancialPassport(
          overallScore: 82,
          totalClosures: 22,
          remainingClosures: 0,
          streak: 12,
          isEligible: true,
          breakdown: createTestScoreBreakdown(
            closureScore: 90,
            debtScore: 80,
            gpsScore: 100,
            cashScore: 70,
          ),
          calculatedAt: DateTime.utc(2026, 11, 17, 10, 0),
        );

        final result = await useCase(
          passport: passport,
          shopId: 'shop-dakar-plateau',
          pinTimestamp: DateTime.utc(2026, 11, 17, 10, 0),
        );

        expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
        final payload =
            (result as Success<SignedPassportPayloadEntity, Failure>).data;

        expect(payload.shopId, equals('shop-dakar-plateau'));
        expect(payload.signature.length, equals(64));
        expect(payload.signature, equals(testSignature));
        expect(payload.publicKey.length, equals(32));
        expect(payload.publicKey, equals(testPubKey));
        expect(payload.visualPin, equals('4821'));
        expect(payload.isValid, isTrue);
        expect(payload.base45Payload, isNotEmpty);
        expect(payload.passport.overallScore, equals(82));
        expect(payload.passport.streak, equals(12));

        verify(
          () => mockCryptoService.getOrCreatePublicKey(
            shopId: 'shop-dakar-plateau',
          ),
        ).called(1);
        verify(
          () => mockCryptoService.sign(any(), shopId: 'shop-dakar-plateau'),
        ).called(1);
        verify(
          () => mockCryptoService.deriveVisualPin(
            signature: any(named: 'signature'),
            calculatedAt: any(named: 'calculatedAt'),
          ),
        ).called(1);
      },
    );

    test(
      'Rejects ineligible passport (isEligible = false, totalClosures < 7)',
      () async {
        final passport = createTestFinancialPassport(
          overallScore: 40,
          totalClosures: 5,
          remainingClosures: 2,
          streak: 2,
          isEligible: false,
        );

        final result = await useCase(passport: passport, shopId: 'shop-1');

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final error =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(error, isA<ValidationFailure>());
        expect(
          error.message,
          equals('Passeport non éligible à la signature officielle'),
        );

        verifyNever(
          () => mockCryptoService.sign(any(), shopId: any(named: 'shopId')),
        );
      },
    );

    test(
      'Rejects passport when totalClosures < 7 even if isEligible flag is true',
      () async {
        final passport = createTestFinancialPassport(
          overallScore: 50,
          totalClosures: 6,
          remainingClosures: 1,
          streak: 3,
          isEligible: true,
        );

        final result = await useCase(passport: passport, shopId: 'shop-1');

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final error =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(error, isA<ValidationFailure>());
        expect(
          error.message,
          equals('Passeport non éligible à la signature officielle'),
        );
      },
    );

    test('Accepts boundary threshold exactly at 7 closures', () async {
      final passport = createTestFinancialPassport(
        overallScore: 65,
        totalClosures: 7,
        remainingClosures: 0,
        streak: 7,
        isEligible: true,
      );

      final result = await useCase(passport: passport, shopId: 'shop-1');

      expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
    });

    test('Defaults pinTimestamp to DateTime.now() if not provided', () async {
      final passport = createTestFinancialPassport(
        overallScore: 70,
        totalClosures: 10,
        isEligible: true,
      );

      final result = await useCase(passport: passport, shopId: 'shop-1');

      expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
      verify(
        () => mockCryptoService.deriveVisualPin(
          signature: any(named: 'signature'),
          calculatedAt: any(named: 'calculatedAt'),
        ),
      ).called(1);
    });

    test('Rejects empty or whitespace shopId with ValidationFailure', () async {
      final passport = createTestFinancialPassport(
        overallScore: 80,
        totalClosures: 15,
        isEligible: true,
      );

      final result = await useCase(passport: passport, shopId: '   ');

      expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
      final error =
          (result as Error<SignedPassportPayloadEntity, Failure>).failure;
      expect(error, isA<ValidationFailure>());
      expect(error.message, equals('Identifiant de boutique invalide'));
    });

    test(
      'Wraps unexpected cryptographic exceptions into CryptoFailure',
      () async {
        final passport = createTestFinancialPassport(
          overallScore: 80,
          totalClosures: 20,
          isEligible: true,
        );

        when(
          () => mockCryptoService.sign(any(), shopId: any(named: 'shopId')),
        ).thenThrow(Exception('Hardware Keystore unavailable'));

        final result = await useCase(passport: passport, shopId: 'shop-1');

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final error =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(error, isA<CryptoFailure>());
        expect(error.message, contains('Erreur lors de la signature'));
      },
    );
  });
}
