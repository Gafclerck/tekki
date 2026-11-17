import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/features/financial_passport/domain/usecases/share_passport_pdf_use_case.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockPdfGeneratorService mockPdfGeneratorService;
  late MockShareService mockShareService;
  late SharePassportPdfUseCase useCase;

  final testPayload = createTestSignedPassportPayload(
    shopId: 'shop-test-123',
    visualPin: '9081',
  );

  final testBytes = Uint8List.fromList([10, 20, 30, 40]);

  setUpAll(() {
    registerFallbackValue(testPayload);
    registerFallbackValue(testBytes);
  });

  setUp(() {
    mockPdfGeneratorService = MockPdfGeneratorService();
    mockShareService = MockShareService();
    useCase = SharePassportPdfUseCase(
      pdfGeneratorService: mockPdfGeneratorService,
      shareService: mockShareService,
    );
  });

  group('SharePassportPdfUseCase Unit Tests', () {
    test(
      'successfully generates PDF and shares file via IShareService',
      () async {
        when(
          () => mockPdfGeneratorService.generatePassportPdf(
            payload: any(named: 'payload'),
            shopName: any(named: 'shopName'),
            emissionDate: any(named: 'emissionDate'),
          ),
        ).thenAnswer((_) async => testBytes);

        when(
          () => mockShareService.sharePdfFile(
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
            subject: any(named: 'subject'),
            text: any(named: 'text'),
          ),
        ).thenAnswer((_) async => true);

        final result = await useCase(
          payload: testPayload,
          shopName: 'Boutique Test',
        );

        expect(result.isSuccess, isTrue);
        result.fold(
          onError: (f) => fail('Should not fail: ${f.message}'),
          onSuccess: (data) => expect(data, isTrue),
        );

        verify(
          () => mockPdfGeneratorService.generatePassportPdf(
            payload: testPayload,
            shopName: 'Boutique Test',
            emissionDate: null,
          ),
        ).called(1);

        verify(
          () => mockShareService.sharePdfFile(
            bytes: testBytes,
            fileName: 'attestation_tekki_shop-test-123.pdf',
            subject: any(named: 'subject'),
            text: any(named: 'text'),
          ),
        ).called(1);
      },
    );

    test('returns ServiceFailure when shareService returns false', () async {
      when(
        () => mockPdfGeneratorService.generatePassportPdf(
          payload: any(named: 'payload'),
          shopName: any(named: 'shopName'),
          emissionDate: any(named: 'emissionDate'),
        ),
      ).thenAnswer((_) async => testBytes);

      when(
        () => mockShareService.sharePdfFile(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          subject: any(named: 'subject'),
          text: any(named: 'text'),
        ),
      ).thenAnswer((_) async => false);

      final result = await useCase(payload: testPayload);

      expect(result.isError, isTrue);
      result.fold(
        onError: (failure) {
          expect(failure, isA<ServiceFailure>());
          expect(
            failure.message,
            contains('Impossible de déclencher la feuille de partage'),
          );
        },
        onSuccess: (_) => fail('Should have failed'),
      );
    });

    test(
      'returns ServiceFailure when pdfGeneratorService throws an exception',
      () async {
        when(
          () => mockPdfGeneratorService.generatePassportPdf(
            payload: any(named: 'payload'),
            shopName: any(named: 'shopName'),
            emissionDate: any(named: 'emissionDate'),
          ),
        ).thenThrow(Exception('PDF generation crash'));

        final result = await useCase(payload: testPayload);

        expect(result.isError, isTrue);
        result.fold(
          onError: (failure) {
            expect(failure, isA<ServiceFailure>());
            expect(failure.message, contains('PDF generation crash'));
          },
          onSuccess: (_) => fail('Should have failed'),
        );
      },
    );
  });
}
