import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/features/financial_passport/data/models/cbor_passport_payload.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  group('CborPassportPayload Unit Tests', () {
    final testPassport = createTestFinancialPassport(
      overallScore: 82,
      totalClosures: 22,
      streak: 12,
      breakdown: createTestScoreBreakdown(
        closureScore: 90,
        debtScore: 80,
        gpsScore: 100,
        cashScore: 70,
      ),
      calculatedAt: DateTime.utc(2026, 11, 17, 12, 0, 0),
    );
    final testPubKey = Uint8List(32)..fillRange(0, 32, 7);
    final testSignature = Uint8List(64)..fillRange(0, 64, 9);

    test(
      'Roundtrip serialization: fromPassport -> toFullCbor -> fromCbor preserves all fields',
      () {
        final payload = CborPassportPayload.fromPassport(
          passport: testPassport,
          shopId: 'shop-test-123',
          publicKey: testPubKey,
          signature: testSignature,
        );

        final cborBytes = payload.toFullCbor();
        expect(cborBytes.length, isPositive);

        final restored = CborPassportPayload.fromCbor(cborBytes);

        expect(restored.version, equals(1));
        expect(restored.shopId, equals('shop-test-123'));
        expect(restored.overallScore, equals(82));
        expect(restored.totalClosures, equals(22));
        expect(restored.streak, equals(12));
        expect(restored.debtScore, equals(80));
        expect(restored.closureScore, equals(90));
        expect(restored.gpsScore, equals(100));
        expect(restored.cashScore, equals(70));
        expect(
          restored.calculatedAtSeconds,
          equals(testPassport.calculatedAt.millisecondsSinceEpoch ~/ 1000),
        );
        expect(restored.publicKey, equals(testPubKey));
        expect(restored.signature, equals(testSignature));
      },
    );

    test('toSignableCbor contains keys 1..11 and omits key 12 (signature)', () {
      final payload = CborPassportPayload.fromPassport(
        passport: testPassport,
        shopId: 'shop-test-123',
        publicKey: testPubKey,
        signature: testSignature,
      );

      final signableBytes = payload.toSignableCbor();
      final decoded = cbor.decode(signableBytes) as CborMap;

      // Keys 1..11 should exist
      for (int i = 1; i <= 11; i++) {
        final hasKey = decoded.entries.any(
          (e) =>
              (e.key is CborSmallInt && (e.key as CborSmallInt).value == i) ||
              (e.key is CborInt && (e.key as CborInt).toInt() == i),
        );
        expect(hasKey, isTrue, reason: 'Key $i must be in signable CBOR');
      }

      // Key 12 should be absent
      final hasKey12 = decoded.entries.any(
        (e) =>
            (e.key is CborSmallInt && (e.key as CborSmallInt).value == 12) ||
            (e.key is CborInt && (e.key as CborInt).toInt() == 12),
      );
      expect(hasKey12, isFalse, reason: 'Key 12 must NOT be in signable CBOR');
    });

    test('toFullCbor throws StateError if signature is null', () {
      final payload = CborPassportPayload.fromPassport(
        passport: testPassport,
        shopId: 'shop-test-123',
        publicKey: testPubKey,
        signature: null,
      );

      expect(() => payload.toFullCbor(), throwsStateError);
    });

    test(
      'toEntity restores genuine FinancialPassportEntity with correct metrics and breakdown',
      () {
        final payload = CborPassportPayload.fromPassport(
          passport: testPassport,
          shopId: 'shop-test-123',
          publicKey: testPubKey,
          signature: testSignature,
        );

        final entity = payload.toEntity();

        expect(entity.overallScore, equals(82));
        expect(entity.totalClosures, equals(22));
        expect(entity.isEligible, isTrue);
        expect(entity.remainingClosures, equals(0));
        expect(entity.streak, equals(12));
        expect(entity.breakdown.closureScore, equals(90));
        expect(entity.breakdown.debtScore, equals(80));
        expect(entity.breakdown.gpsScore, equals(100));
        expect(entity.breakdown.cashScore, equals(70));
        expect(entity.calculatedAt, equals(testPassport.calculatedAt));
      },
    );

    test(
      'fromCbor rejects non-map CBOR or corrupted payload with FormatException',
      () {
        // Non-map CBOR (e.g. CborString)
        final nonMapBytes = cbor.encode(CborString('Not a map'));
        expect(
          () => CborPassportPayload.fromCbor(nonMapBytes),
          throwsFormatException,
        );

        // Incomplete map missing mandatory key (e.g. key 2 shopId)
        final incompleteMap = CborMap({
          const CborSmallInt(1): const CborSmallInt(1),
          const CborSmallInt(3): const CborSmallInt(80),
        });
        final incompleteBytes = cbor.encode(incompleteMap);
        expect(
          () => CborPassportPayload.fromCbor(incompleteBytes),
          throwsFormatException,
        );

        // Random garbage bytes
        expect(
          () => CborPassportPayload.fromCbor([0xFF, 0xFF, 0xFF]),
          throwsFormatException,
        );

        // Version mismatch (version != 1)
        final p = CborPassportPayload.fromPassport(
          passport: testPassport,
          shopId: 'shop-test-123',
          publicKey: testPubKey,
          signature: testSignature,
          version: 2,
        );
        expect(
          () => CborPassportPayload.fromCbor(p.toFullCbor()),
          throwsFormatException,
        );
      },
    );

    test('Equatable value equality', () {
      final p1 = CborPassportPayload.fromPassport(
        passport: testPassport,
        shopId: 'shop-1',
        publicKey: testPubKey,
        signature: testSignature,
      );
      final p2 = CborPassportPayload.fromPassport(
        passport: testPassport,
        shopId: 'shop-1',
        publicKey: testPubKey,
        signature: testSignature,
      );

      expect(p1, equals(p2));
    });
  });
}
