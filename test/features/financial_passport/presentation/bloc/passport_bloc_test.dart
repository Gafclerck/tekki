import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import '../../../../helpers/fixtures.dart';

class MockCalculateFinancialPassportUseCase extends Mock
    implements CalculateFinancialPassportUseCase {}

class MockGenerateSignedPassportUseCase extends Mock
    implements GenerateSignedPassportUseCase {}

void main() {
  late MockCalculateFinancialPassportUseCase mockCalculateUseCase;
  late MockGenerateSignedPassportUseCase mockGenerateUseCase;
  late PassportBloc bloc;

  final testDate = DateTime.utc(2026, 11, 17, 14, 30, 15);

  final eligiblePassport = createTestFinancialPassport(
    overallScore: 82,
    streak: 12,
    totalClosures: 22,
    isEligible: true,
    calculatedAt: testDate,
  );

  final ineligiblePassport = createTestFinancialPassport(
    overallScore: 40,
    streak: 3,
    totalClosures: 4,
    remainingClosures: 3,
    isEligible: false,
    calculatedAt: testDate,
  );

  final testSignedPayload = createTestSignedPassportPayload(
    passport: eligiblePassport,
    visualPin: '4821',
    base45Payload: 'TEKKI-BASE45-PAYLOAD',
  );

  setUpAll(() {
    registerFallbackValue(eligiblePassport);
  });

  setUp(() {
    mockCalculateUseCase = MockCalculateFinancialPassportUseCase();
    mockGenerateUseCase = MockGenerateSignedPassportUseCase();
    bloc = PassportBloc(
      calculateFinancialPassportUseCase: mockCalculateUseCase,
      generateSignedPassportUseCase: mockGenerateUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('PassportBloc Unit Tests', () {
    test('initial state is PassportInitial', () {
      expect(bloc.state, const PassportInitial());
    });

    blocTest<PassportBloc, PassportState>(
      'emits [PassportLoading, PassportEncouragementLoaded] when passport is ineligible (< 7 closures)',
      build: () {
        when(
          () => mockCalculateUseCase(asOf: any(named: 'asOf')),
        ).thenAnswer((_) async => Success(ineligiblePassport));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPassportEvent(asOf: testDate)),
      expect: () => [
        const PassportLoading(),
        PassportEncouragementLoaded(
          passport: ineligiblePassport,
          closuresNeeded: 3,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockGenerateUseCase(
            passport: any(named: 'passport'),
            shopId: any(named: 'shopId'),
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        );
      },
    );

    blocTest<PassportBloc, PassportState>(
      'emits [PassportLoading, PassportActiveLoaded] when passport is eligible',
      build: () {
        when(
          () => mockCalculateUseCase(asOf: any(named: 'asOf')),
        ).thenAnswer((_) async => Success(eligiblePassport));
        when(
          () => mockGenerateUseCase(
            passport: eligiblePassport,
            shopId: 'shop-1',
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        ).thenAnswer((_) async => Success(testSignedPayload));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(LoadPassportEvent(asOf: testDate, shopId: 'shop-1')),
      expect: () => [
        const PassportLoading(),
        PassportActiveLoaded(
          passport: eligiblePassport,
          signedPayload: testSignedPayload,
          secondsRemainingInMinute: 45, // 60 - 15
          lastUpdated: testDate,
        ),
      ],
    );

    blocTest<PassportBloc, PassportState>(
      'emits [PassportLoading, PassportError] on calculate failure',
      build: () {
        when(() => mockCalculateUseCase(asOf: any(named: 'asOf'))).thenAnswer(
          (_) async => const Error(DatabaseFailure(message: 'DB error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPassportEvent(asOf: testDate)),
      expect: () => [
        const PassportLoading(),
        const PassportError(message: 'DB error'),
      ],
    );

    blocTest<PassportBloc, PassportState>(
      'emits [PassportLoading, PassportError] on signature failure',
      build: () {
        when(
          () => mockCalculateUseCase(asOf: any(named: 'asOf')),
        ).thenAnswer((_) async => Success(eligiblePassport));
        when(
          () => mockGenerateUseCase(
            passport: eligiblePassport,
            shopId: any(named: 'shopId'),
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        ).thenAnswer(
          (_) async => const Error(CryptoFailure(message: 'Crypto error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPassportEvent(asOf: testDate)),
      expect: () => [
        const PassportLoading(),
        const PassportError(message: 'Crypto error'),
      ],
    );

    blocTest<PassportBloc, PassportState>(
      'RefreshPinTickEvent during same minute updates secondsRemainingInMinute without regenerating payload',
      build: () => bloc,
      seed: () => PassportActiveLoaded(
        passport: eligiblePassport,
        signedPayload: testSignedPayload,
        secondsRemainingInMinute: 45,
        lastUpdated: testDate,
      ),
      act: (bloc) => bloc.add(
        RefreshPinTickEvent(now: testDate.add(const Duration(seconds: 10))),
      ),
      expect: () => [
        PassportActiveLoaded(
          passport: eligiblePassport,
          signedPayload: testSignedPayload,
          secondsRemainingInMinute: 35, // 60 - 25
          lastUpdated: testDate,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockGenerateUseCase(
            passport: any(named: 'passport'),
            shopId: any(named: 'shopId'),
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        );
      },
    );

    final nextMinuteDate = testDate.add(const Duration(minutes: 1));
    final nextMinutePayload = createTestSignedPassportPayload(
      passport: eligiblePassport,
      visualPin: '9942',
      base45Payload: 'TEKKI-BASE45-PAYLOAD-V2',
    );

    blocTest<PassportBloc, PassportState>(
      'RefreshPinTickEvent across minute boundary regenerates signature and visual PIN',
      build: () {
        when(
          () => mockGenerateUseCase(
            passport: eligiblePassport,
            shopId: 'default-shop',
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        ).thenAnswer((_) async => Success(nextMinutePayload));
        return bloc;
      },
      seed: () => PassportActiveLoaded(
        passport: eligiblePassport,
        signedPayload: testSignedPayload,
        secondsRemainingInMinute: 1,
        lastUpdated: testDate,
      ),
      act: (bloc) => bloc.add(RefreshPinTickEvent(now: nextMinuteDate)),
      expect: () => [
        PassportActiveLoaded(
          passport: eligiblePassport,
          signedPayload: nextMinutePayload,
          secondsRemainingInMinute: 45,
          lastUpdated: nextMinuteDate,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGenerateUseCase(
            passport: eligiblePassport,
            shopId: 'default-shop',
            pinTimestamp: any(named: 'pinTimestamp'),
          ),
        ).called(1);
      },
    );

    blocTest<PassportBloc, PassportState>(
      'RefreshPinTickEvent ignores when not in PassportActiveLoaded state',
      build: () => bloc,
      seed: () => const PassportInitial(),
      act: (bloc) => bloc.add(RefreshPinTickEvent(now: testDate)),
      expect: () => <PassportState>[],
    );
  });
}
