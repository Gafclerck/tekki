import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCalculateFinancialPassportUseCase mockCalculateUseCase;
  late MockGenerateSignedPassportUseCase mockGenerateUseCase;
  late MockSharePassportPdfUseCase mockShareUseCase;

  final testDate = DateTime.utc(2026, 11, 17, 12, 0);
  final eligiblePassport = createTestFinancialPassport(
    overallScore: 82,
    streak: 12,
    totalClosures: 22,
    isEligible: true,
    calculatedAt: testDate,
  );
  final signedPayload = createTestSignedPassportPayload(
    passport: eligiblePassport,
    visualPin: '5841',
  );

  final activeState = PassportActiveLoaded(
    passport: eligiblePassport,
    signedPayload: signedPayload,
    secondsRemainingInMinute: 45,
    lastUpdated: testDate,
  );

  setUpAll(() {
    registerFallbackValue(signedPayload);
  });

  setUp(() {
    mockCalculateUseCase = MockCalculateFinancialPassportUseCase();
    mockGenerateUseCase = MockGenerateSignedPassportUseCase();
    mockShareUseCase = MockSharePassportPdfUseCase();
  });

  group('PassportBloc SharePassportPdfEvent Unit Tests', () {
    blocTest<PassportBloc, PassportState>(
      'emits [isSharingPdf: true, pdfSharedSuccessfully: true] when share succeeds',
      build: () => PassportBloc(
        calculateFinancialPassportUseCase: mockCalculateUseCase,
        generateSignedPassportUseCase: mockGenerateUseCase,
        sharePassportPdfUseCase: mockShareUseCase,
      ),
      seed: () => activeState,
      setUp: () {
        when(
          () => mockShareUseCase(
            payload: any(named: 'payload'),
            shopName: any(named: 'shopName'),
            emissionDate: any(named: 'emissionDate'),
          ),
        ).thenAnswer((_) async => Result.success<bool, Failure>(true));
      },
      act: (bloc) =>
          bloc.add(const SharePassportPdfEvent(shopName: 'Boutique Test')),
      expect: () => [
        activeState.copyWith(
          isSharingPdf: true,
          clearShareError: true,
          pdfSharedSuccessfully: false,
        ),
        activeState.copyWith(isSharingPdf: false, pdfSharedSuccessfully: true),
      ],
      verify: (_) {
        verify(
          () => mockShareUseCase(
            payload: signedPayload,
            shopName: 'Boutique Test',
            emissionDate: null,
          ),
        ).called(1);
      },
    );

    blocTest<PassportBloc, PassportState>(
      'emits [isSharingPdf: true, sharePdfError: ...] when share fails',
      build: () => PassportBloc(
        calculateFinancialPassportUseCase: mockCalculateUseCase,
        generateSignedPassportUseCase: mockGenerateUseCase,
        sharePassportPdfUseCase: mockShareUseCase,
      ),
      seed: () => activeState,
      setUp: () {
        when(
          () => mockShareUseCase(
            payload: any(named: 'payload'),
            shopName: any(named: 'shopName'),
            emissionDate: any(named: 'emissionDate'),
          ),
        ).thenAnswer(
          (_) async => Result.failure<bool, Failure>(
            const ServiceFailure(
              message: 'Impossible d\'ouvrir la feuille de partage',
            ),
          ),
        );
      },
      act: (bloc) => bloc.add(const SharePassportPdfEvent()),
      expect: () => [
        activeState.copyWith(
          isSharingPdf: true,
          clearShareError: true,
          pdfSharedSuccessfully: false,
        ),
        activeState.copyWith(
          isSharingPdf: false,
          sharePdfError: 'Impossible d\'ouvrir la feuille de partage',
        ),
      ],
    );

    blocTest<PassportBloc, PassportState>(
      'ignores SharePassportPdfEvent when already sharing (anti-double-click)',
      build: () => PassportBloc(
        calculateFinancialPassportUseCase: mockCalculateUseCase,
        generateSignedPassportUseCase: mockGenerateUseCase,
        sharePassportPdfUseCase: mockShareUseCase,
      ),
      seed: () => activeState.copyWith(isSharingPdf: true),
      act: (bloc) => bloc.add(const SharePassportPdfEvent()),
      expect: () => <PassportState>[],
      verify: (_) {
        verifyNever(
          () => mockShareUseCase(
            payload: any(named: 'payload'),
            shopName: any(named: 'shopName'),
          ),
        );
      },
    );

    blocTest<PassportBloc, PassportState>(
      'does nothing when state is not PassportActiveLoaded',
      build: () => PassportBloc(
        calculateFinancialPassportUseCase: mockCalculateUseCase,
        generateSignedPassportUseCase: mockGenerateUseCase,
        sharePassportPdfUseCase: mockShareUseCase,
      ),
      seed: () => const PassportInitial(),
      act: (bloc) => bloc.add(const SharePassportPdfEvent()),
      expect: () => <PassportState>[],
    );
  });
}
