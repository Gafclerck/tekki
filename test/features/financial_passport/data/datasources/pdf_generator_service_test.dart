import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/features/financial_passport/data/datasources/pdf_generator_service_impl.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('PdfGeneratorServiceImpl Unit Tests', () {
    const service = PdfGeneratorServiceImpl();

    test(
      'generates valid vector PDF bytes with %PDF magic header in less than 2 seconds',
      () async {
        final eligiblePassport = createTestFinancialPassport(
          overallScore: 82,
          streak: 12,
          totalClosures: 22,
        );
        final payload = createTestSignedPassportPayload(
          passport: eligiblePassport,
          shopId: 'boutique-dakar-01',
          visualPin: '7392',
          base45Payload: 'TEKKI-VALID-BASE45-RFC9285',
        );

        final stopwatch = Stopwatch()..start();
        final pdfBytes = await service.generatePassportPdf(
          payload: payload,
          shopName: 'Boutique Keur Serigne Bi',
          emissionDate: DateTime.utc(2026, 11, 17, 12, 0),
        );
        stopwatch.stop();

        // Vérification performance NFR3 (< 2000 ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));

        // Vérification validité PDF (%PDF- header)
        expect(pdfBytes, isNotEmpty);
        expect(pdfBytes.length, greaterThan(1000));
        final header = ascii.decode(pdfBytes.sublist(0, 5));
        expect(header, '%PDF-');
      },
    );

    test(
      'generates valid PDF when shopName is null or empty (fallback to shopId)',
      () async {
        final passport = createTestFinancialPassport(overallScore: 68);
        final payload = createTestSignedPassportPayload(
          passport: passport,
          shopId: 'shop-fallback-id',
        );

        final pdfBytes = await service.generatePassportPdf(
          payload: payload,
          shopName: null,
        );

        expect(pdfBytes, isNotEmpty);
        final header = ascii.decode(pdfBytes.sublist(0, 5));
        expect(header, '%PDF-');
      },
    );

    test('generates PDF for different rating tiers without error', () async {
      for (final score in [95, 75, 65, 45]) {
        final passport = createTestFinancialPassport(overallScore: score);
        final payload = createTestSignedPassportPayload(passport: passport);

        final bytes = await service.generatePassportPdf(payload: payload);
        expect(bytes, isNotEmpty);
      }
    });
  });
}
