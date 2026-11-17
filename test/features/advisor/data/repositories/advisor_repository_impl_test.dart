import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/data/repositories/advisor_repository_impl.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockClosureRepository mockClosureRepository;
  late MockDebtRepository mockDebtRepository;
  late AdvisorRepositoryImpl repository;

  final fixedNow = DateTime.utc(2026, 11, 17, 12, 0);

  setUp(() {
    mockClosureRepository = MockClosureRepository();
    mockDebtRepository = MockDebtRepository();
    repository = AdvisorRepositoryImpl(
      closureRepository: mockClosureRepository,
      debtRepository: mockDebtRepository,
    );
  });

  group('AdvisorRepositoryImpl evaluateFinancialHealth', () {
    test(
      'successfully aggregates local data and computes financial health',
      () async {
        final closures = [
          createTestDailyClosure(
            id: 'c-1',
            closureDate: '2026-11-17',
            createdAt: fixedNow,
          ),
        ];
        final debts = <DebtEntity>[];
        const velocity = RecoveryVelocityEntity(
          rate: 100,
          totalDueAmount: 0,
          totalRecoveredAmount: 0,
          healthStatus: 'Excellent',
        );

        when(
          () =>
              mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
        ).thenAnswer((_) async => Success(closures));
        when(
          () => mockDebtRepository.getActiveDebts(),
        ).thenAnswer((_) async => Success(debts));
        when(
          () => mockDebtRepository.getRecoveryVelocity(
            asOf: any(named: 'asOf'),
            windowDays: any(named: 'windowDays'),
          ),
        ).thenAnswer((_) async => const Success(velocity));

        final result = await repository.evaluateFinancialHealth(
          asOf: fixedNow,
          windowDays: 30,
        );

        expect(result, isA<Success<FinancialHealthEntity, Failure>>());
        final health = (result as Success<FinancialHealthEntity, Failure>).data;
        expect(health.indicators.length, equals(4));
        verify(
          () =>
              mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
        ).called(1);
        verify(() => mockDebtRepository.getActiveDebts()).called(1);
        verify(
          () => mockDebtRepository.getRecoveryVelocity(
            asOf: fixedNow,
            windowDays: 30,
          ),
        ).called(1);
      },
    );

    test('returns Error when closureRepository returns Error', () async {
      when(
        () => mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
      ).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Closure DB error')),
      );
      when(
        () => mockDebtRepository.getActiveDebts(),
      ).thenAnswer((_) async => const Success(<DebtEntity>[]));
      when(
        () => mockDebtRepository.getRecoveryVelocity(
          asOf: any(named: 'asOf'),
          windowDays: any(named: 'windowDays'),
        ),
      ).thenAnswer(
        (_) async => const Success(
          RecoveryVelocityEntity(
            rate: 100,
            totalDueAmount: 0,
            totalRecoveredAmount: 0,
            healthStatus: 'Excellent',
          ),
        ),
      );

      final result = await repository.evaluateFinancialHealth(asOf: fixedNow);

      expect(result, isA<Error<FinancialHealthEntity, Failure>>());
      expect(
        (result as Error<FinancialHealthEntity, Failure>).failure.message,
        contains('Closure DB error'),
      );
    });

    test(
      'returns Error when debtRepository.getActiveDebts returns Error',
      () async {
        when(
          () =>
              mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
        ).thenAnswer((_) async => const Success(<DailyClosureEntity>[]));
        when(() => mockDebtRepository.getActiveDebts()).thenAnswer(
          (_) async => const Error(DatabaseFailure(message: 'Debt DB error')),
        );
        when(
          () => mockDebtRepository.getRecoveryVelocity(
            asOf: any(named: 'asOf'),
            windowDays: any(named: 'windowDays'),
          ),
        ).thenAnswer(
          (_) async => const Success(
            RecoveryVelocityEntity(
              rate: 100,
              totalDueAmount: 0,
              totalRecoveredAmount: 0,
              healthStatus: 'Excellent',
            ),
          ),
        );

        final result = await repository.evaluateFinancialHealth(asOf: fixedNow);

        expect(result, isA<Error<FinancialHealthEntity, Failure>>());
        expect(
          (result as Error<FinancialHealthEntity, Failure>).failure.message,
          contains('Debt DB error'),
        );
      },
    );

    test(
      'returns Error with DatabaseFailure when DatabaseException is thrown',
      () async {
        when(
          () =>
              mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
        ).thenThrow(const DatabaseException('Drift connection failed'));

        final result = await repository.evaluateFinancialHealth(asOf: fixedNow);

        expect(result, isA<Error<FinancialHealthEntity, Failure>>());
        expect(
          (result as Error<FinancialHealthEntity, Failure>).failure.message,
          contains('Drift connection failed'),
        );
      },
    );
  });
}
