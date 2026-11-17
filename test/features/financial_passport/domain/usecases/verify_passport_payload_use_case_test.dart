import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/crypto/base45.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/data/models/cbor_passport_payload.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

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
  group('VerifyPassportPayloadUseCase Unit & Anti-Fraude Tests', () {
    late MockCryptoSignatureService mockCryptoService;
    late VerifyPassportPayloadUseCase useCase;

    final testPubKey = Uint8List(32)..fillRange(0, 32, 5);
    final testSignature = Uint8List(64)..fillRange(0, 64, 8);

    setUp(() {
      mockCryptoService = MockCryptoSignatureService();
      useCase = VerifyPassportPayloadUseCase(
        cryptoSignatureService: mockCryptoService,
      );

      when(
        () => mockCryptoService.verify(
          any(),
          signature: any(named: 'signature'),
          publicKey: any(named: 'publicKey'),
        ),
      ).thenAnswer((_) async => true);

      when(
        () => mockCryptoService.deriveVisualPin(
          signature: any(named: 'signature'),
          calculatedAt: any(named: 'calculatedAt'),
          timestampSeconds: any(named: 'timestampSeconds'),
        ),
      ).thenAnswer((_) async => '9876');
    });

    String buildValidBase45Payload({
      int overallScore = 82,
      int totalClosures = 22,
      int streak = 12,
      Uint8List? signature,
      Uint8List? publicKey,
    }) {
      final passport = createTestFinancialPassport(
        overallScore: overallScore,
        totalClosures: totalClosures,
        streak: streak,
        breakdown: createTestScoreBreakdown(
          closureScore: 90,
          debtScore: 80,
          gpsScore: 100,
          cashScore: 70,
        ),
        calculatedAt: DateTime.utc(2026, 11, 17, 10, 0),
      );

      final payload = CborPassportPayload.fromPassport(
        passport: passport,
        shopId: 'shop-test-456',
        publicKey: publicKey ?? testPubKey,
        signature: signature ?? testSignature,
      );

      return Base45.encode(payload.toFullCbor());
    }

    test(
      'Nominal D2D verification: valid payload restores original metrics faithfully',
      () async {
        final base45 = buildValidBase45Payload(
          overallScore: 85,
          totalClosures: 25,
          streak: 15,
        );

        final result = await useCase(base45);

        expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
        final entity =
            (result as Success<SignedPassportPayloadEntity, Failure>).data;

        expect(entity.isValid, isTrue);
        expect(entity.shopId, equals('shop-test-456'));
        expect(entity.visualPin, equals('9876'));
        expect(entity.passport.overallScore, equals(85));
        expect(entity.passport.totalClosures, equals(25));
        expect(entity.passport.streak, equals(15));
        expect(entity.passport.isEligible, isTrue);
        expect(entity.signature, equals(testSignature));
        expect(entity.publicKey, equals(testPubKey));

        verify(
          () => mockCryptoService.verify(
            any(),
            signature: testSignature,
            publicKey: testPubKey,
          ),
        ).called(1);
      },
    );

    test(
      'Verifies successfully against expected public key when matching',
      () async {
        final base45 = buildValidBase45Payload();

        final result = await useCase(base45, expectedPublicKey: testPubKey);

        expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
      },
    );

    test(
      'Rejects when expected public key does not match embedded key',
      () async {
        final base45 = buildValidBase45Payload();
        final differentKey = Uint8List(32)..fillRange(0, 32, 99);

        final result = await useCase(base45, expectedPublicKey: differentKey);

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final failure =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(failure, isA<CryptoFailure>());
        expect(
          failure.message,
          equals('Signature invalide ou charge utile corrompue'),
        );
      },
    );

    test(
      'Rejects when crypto service indicates invalid signature (isValid = false)',
      () async {
        final base45 = buildValidBase45Payload();

        when(
          () => mockCryptoService.verify(
            any(),
            signature: any(named: 'signature'),
            publicKey: any(named: 'publicKey'),
          ),
        ).thenAnswer((_) async => false);

        final result = await useCase(base45);

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final failure =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(failure, isA<CryptoFailure>());
        expect(
          failure.message,
          equals('Signature invalide ou charge utile corrompue'),
        );
      },
    );

    test('Rejects empty or whitespace payload immediately', () async {
      final result1 = await useCase('');
      expect(result1, isA<Error<SignedPassportPayloadEntity, Failure>>());

      final result2 = await useCase('   ');
      expect(result2, isA<Error<SignedPassportPayloadEntity, Failure>>());
    });

    test('Rejects corrupted Base45 payload', () async {
      final result = await useCase('NOT_A_VALID_BASE45_STRING_@#\$%');
      expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
      final failure =
          (result as Error<SignedPassportPayloadEntity, Failure>).failure;
      expect(failure, isA<CryptoFailure>());
    });

    test('Rejects corrupted CBOR structure', () async {
      // Valid Base45 encoding of non-CBOR garbage
      final garbageBase45 = Base45.encode([1, 2, 3, 4, 5]);
      final result = await useCase(garbageBase45);

      expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
      final failure =
          (result as Error<SignedPassportPayloadEntity, Failure>).failure;
      expect(failure, isA<CryptoFailure>());
    });

    test(
      'Visual PIN verification: accepts PIN matching current minute',
      () async {
        final base45 = buildValidBase45Payload();
        final now = DateTime.utc(2026, 11, 17, 12, 30, 0);

        when(
          () => mockCryptoService.deriveVisualPin(
            signature: any(named: 'signature'),
            calculatedAt: now,
          ),
        ).thenAnswer((_) async => '1234');

        final result = await useCase(
          base45,
          visualPinToVerify: '1234',
          verificationTime: now,
        );

        expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
        final data =
            (result as Success<SignedPassportPayloadEntity, Failure>).data;
        expect(data.visualPin, equals('1234'));
      },
    );

    test(
      'Visual PIN verification: accepts PIN matching previous minute (1-minute drift tolerance)',
      () async {
        final base45 = buildValidBase45Payload();
        final now = DateTime.utc(2026, 11, 17, 12, 30, 5);
        final prevMinute = now.subtract(const Duration(minutes: 1));

        when(
          () => mockCryptoService.deriveVisualPin(
            signature: any(named: 'signature'),
            calculatedAt: now,
          ),
        ).thenAnswer((_) async => '9999');

        when(
          () => mockCryptoService.deriveVisualPin(
            signature: any(named: 'signature'),
            calculatedAt: prevMinute,
          ),
        ).thenAnswer((_) async => '1234');

        final result = await useCase(
          base45,
          visualPinToVerify: '1234',
          verificationTime: now,
        );

        expect(result, isA<Success<SignedPassportPayloadEntity, Failure>>());
        final data =
            (result as Success<SignedPassportPayloadEntity, Failure>).data;
        expect(data.visualPin, equals('1234'));
      },
    );

    test(
      'Visual PIN verification: rejects expired or mismatched PIN with CryptoFailure',
      () async {
        final base45 = buildValidBase45Payload();
        final now = DateTime.utc(2026, 11, 17, 12, 30, 0);

        when(
          () => mockCryptoService.deriveVisualPin(
            signature: any(named: 'signature'),
            calculatedAt: any(named: 'calculatedAt'),
          ),
        ).thenAnswer((_) async => '8888');

        final result = await useCase(
          base45,
          visualPinToVerify: '1234',
          verificationTime: now,
        );

        expect(result, isA<Error<SignedPassportPayloadEntity, Failure>>());
        final failure =
            (result as Error<SignedPassportPayloadEntity, Failure>).failure;
        expect(failure, isA<CryptoFailure>());
      },
    );
  });

  group('End-to-End Cryptographic Anti-Fraude Integration Tests', () {
    test(
      'Generate -> Verify roundtrip with real Ed25519 & HMAC passes 100% offline',
      () async {
        final storage = InMemorySecureKeyStorage();
        final cryptoService = CryptoSignatureService(secureKeyStorage: storage);
        final generateUseCase = GenerateSignedPassportUseCase(
          cryptoSignatureService: cryptoService,
        );
        final verifyUseCase = VerifyPassportPayloadUseCase(
          cryptoSignatureService: cryptoService,
        );

        final originalPassport = createTestFinancialPassport(
          overallScore: 82,
          totalClosures: 22,
          remainingClosures: 0,
          streak: 12,
          breakdown: createTestScoreBreakdown(
            closureScore: 90,
            debtScore: 80,
            gpsScore: 100,
            cashScore: 70,
          ),
          calculatedAt: DateTime.utc(2026, 11, 17, 12, 34, 56),
        );

        // 1. Génération
        final genResult = await generateUseCase(
          passport: originalPassport,
          shopId: 'boutique-keur-massar',
          pinTimestamp: originalPassport.calculatedAt,
        );
        expect(genResult, isA<Success<SignedPassportPayloadEntity, Failure>>());
        final signedEntity =
            (genResult as Success<SignedPassportPayloadEntity, Failure>).data;

        expect(signedEntity.base45Payload, isNotEmpty);
        expect(signedEntity.signature.length, equals(64));
        expect(signedEntity.publicKey.length, equals(32));
        expect(RegExp(r'^\d{4}$').hasMatch(signedEntity.visualPin), isTrue);

        // 2. Vérification nominale D2D
        final verifResult = await verifyUseCase(signedEntity.base45Payload);
        expect(
          verifResult,
          isA<Success<SignedPassportPayloadEntity, Failure>>(),
        );
        final verifiedEntity =
            (verifResult as Success<SignedPassportPayloadEntity, Failure>).data;

        expect(verifiedEntity.isValid, isTrue);
        expect(verifiedEntity.shopId, equals('boutique-keur-massar'));
        expect(verifiedEntity.passport.overallScore, equals(82));
        expect(verifiedEntity.passport.totalClosures, equals(22));
        expect(verifiedEntity.passport.streak, equals(12));
        expect(verifiedEntity.passport.breakdown.closureScore, equals(90));
        expect(verifiedEntity.visualPin, equals(signedEntity.visualPin));

        // 2b. Vérification avec PIN visuel concordant
        final pinVerifResult = await verifyUseCase(
          signedEntity.base45Payload,
          visualPinToVerify: signedEntity.visualPin,
          verificationTime: originalPassport.calculatedAt,
        );
        expect(
          pinVerifResult,
          isA<Success<SignedPassportPayloadEntity, Failure>>(),
        );

        // 2c. Vérification avec PIN visuel erroné (rejet anti-rejeu)
        final badPinResult = await verifyUseCase(
          signedEntity.base45Payload,
          visualPinToVerify: '0000',
          verificationTime: originalPassport.calculatedAt,
        );
        expect(
          badPinResult,
          isA<Error<SignedPassportPayloadEntity, Failure>>(),
        );

        // 3. Altération frauduleuse d'un seul caractère de la payload Base45
        final chars = signedEntity.base45Payload.split('');
        chars[5] = chars[5] == 'A' ? 'B' : 'A';
        final tamperedBase45 = chars.join();

        final fraudResult1 = await verifyUseCase(tamperedBase45);
        expect(
          fraudResult1,
          isA<Error<SignedPassportPayloadEntity, Failure>>(),
        );
        final failure1 =
            (fraudResult1 as Error<SignedPassportPayloadEntity, Failure>)
                .failure;
        expect(
          failure1.message,
          equals('Signature invalide ou charge utile corrompue'),
        );

        // 4. Altération frauduleuse du score à l'intérieur du CBOR (score 82 -> 99)
        final rawCborBytes = Base45.decode(signedEntity.base45Payload);
        final decodedMap = cbor.decode(rawCborBytes) as CborMap;

        // Re-encoder avec le score modifié mais en conservant l'ancienne signature
        final alteredMap = <CborValue, CborValue>{};
        for (final entry in decodedMap.entries) {
          if (entry.key is CborSmallInt &&
              (entry.key as CborSmallInt).value == 3) {
            alteredMap[entry.key] = const CborSmallInt(
              99,
            ); // Fraude: score gonflé
          } else {
            alteredMap[entry.key] = entry.value;
          }
        }
        final forgedCbor = Uint8List.fromList(cbor.encode(CborMap(alteredMap)));
        final forgedBase45 = Base45.encode(forgedCbor);

        final fraudResult2 = await verifyUseCase(forgedBase45);
        expect(
          fraudResult2,
          isA<Error<SignedPassportPayloadEntity, Failure>>(),
        );
        final failure2 =
            (fraudResult2 as Error<SignedPassportPayloadEntity, Failure>)
                .failure;
        expect(
          failure2.message,
          equals('Signature invalide ou charge utile corrompue'),
        );
      },
    );
  });
}
