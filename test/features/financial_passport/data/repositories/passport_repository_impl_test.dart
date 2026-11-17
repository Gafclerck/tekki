import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/data/repositories/passport_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockClosureRepository mockClosureRepository;
  late MockDebtRepository mockDebtRepository;
  late PassportRepositoryImpl repository;

  final now = DateTime.utc(2026, 11, 17, 12, 0);

  setUp(() {
    mockClosureRepository = MockClosureRepository();
    mockDebtRepository = MockDebtRepository();
    repository = PassportRepositoryImpl(
      closureRepository: mockClosureRepository,
      debtRepository: mockDebtRepository,
    );

    // Default stubbing for parallel calls
    when(
      () => mockClosureRepository.getAllClosures(limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockClosureRepository.getActiveStreak(
        referenceDate: any(named: 'referenceDate'),
      ),
    ).thenAnswer((_) async => const Success(0));
    when(
      () => mockDebtRepository.getRecoveryVelocity(
        asOf: any(named: 'asOf'),
        windowDays: any(named: 'windowDays'),
      ),
    ).thenAnswer((_) async => Success(createTestRecoveryVelocity()));
  });

  group('PassportRepositoryImpl', () {
    test(
      'returns Success(FinancialPassportEntity) when all sources return data successfully',
      () async {
        final closures = List.generate(
          10,
          (i) => createTestDailyClosure(
            id: 'c-$i',
            closureDate: '2026-11-${(8 + i).toString().padLeft(2, '0')}',
            totalSalesAmount: 15000,
            cashCounted: 15000,
          ),
        );
        final recoveryVelocity = createTestRecoveryVelocity(rate: 90);

        when(
          () => mockClosureRepository.getAllClosures(limit: 100),
        ).thenAnswer((_) async => Success(closures));
        when(
          () => mockClosureRepository.getActiveStreak(referenceDate: now),
        ).thenAnswer((_) async => const Success(5));
        when(
          () =>
              mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
        ).thenAnswer((_) async => Success(recoveryVelocity));

        final result = await repository.getFinancialPassport(
          asOf: now,
          windowDays: 30,
        );

        expect(result.isSuccess, isTrue);
        final passport = (result as Success).data;
        expect(passport.totalClosures, 10);
        expect(passport.isEligible, isTrue);
        expect(passport.remainingClosures, 0);
        expect(passport.streak, 5);
        expect(passport.breakdown.debtScore, 90);
        expect(passport.overallScore, greaterThan(0));

        verify(
          () => mockClosureRepository.getAllClosures(limit: 100),
        ).called(1);
        verify(
          () => mockClosureRepository.getActiveStreak(referenceDate: now),
        ).called(1);
        verify(
          () =>
              mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
        ).called(1);
      },
    );

    test('returns Error when getAllClosures fails', () async {
      when(() => mockClosureRepository.getAllClosures(limit: 100)).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'DB error closures')),
      );
      when(
        () => mockClosureRepository.getActiveStreak(referenceDate: now),
      ).thenAnswer((_) async => const Success(0));
      when(
        () => mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
      ).thenAnswer((_) async => Success(createTestRecoveryVelocity()));

      final result = await repository.getFinancialPassport(
        asOf: now,
        windowDays: 30,
      );

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure,
        const DatabaseFailure(message: 'DB error closures'),
      );
    });

    test(
      'uses dynamic limit max(100, windowDays * 2) for long windows',
      () async {
        when(
          () => mockClosureRepository.getAllClosures(limit: 120),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => mockClosureRepository.getActiveStreak(referenceDate: now),
        ).thenAnswer((_) async => const Success(0));
        when(
          () =>
              mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 60),
        ).thenAnswer((_) async => Success(createTestRecoveryVelocity()));

        final result = await repository.getFinancialPassport(
          asOf: now,
          windowDays: 60,
        );

        expect(result.isSuccess, isTrue);
        verify(
          () => mockClosureRepository.getAllClosures(limit: 120),
        ).called(1);
      },
    );

    test('returns Error when getActiveStreak fails', () async {
      when(
        () => mockClosureRepository.getAllClosures(limit: 100),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockClosureRepository.getActiveStreak(referenceDate: now),
      ).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Streak error')),
      );

      final result = await repository.getFinancialPassport(
        asOf: now,
        windowDays: 30,
      );

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure,
        const DatabaseFailure(message: 'Streak error'),
      );
    });

    test('returns Error when getRecoveryVelocity fails', () async {
      when(
        () => mockClosureRepository.getAllClosures(limit: 100),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockClosureRepository.getActiveStreak(referenceDate: now),
      ).thenAnswer((_) async => const Success(0));
      when(
        () => mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
      ).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Debt error')),
      );

      final result = await repository.getFinancialPassport(
        asOf: now,
        windowDays: 30,
      );

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure,
        const DatabaseFailure(message: 'Debt error'),
      );
    });

    test('catches DatabaseException and converts to DatabaseFailure', () async {
      when(
        () => mockClosureRepository.getAllClosures(limit: 100),
      ).thenThrow(const DatabaseException('Low-level SQLite exception'));
      when(
        () => mockClosureRepository.getActiveStreak(referenceDate: now),
      ).thenAnswer((_) async => const Success(0));
      when(
        () => mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
      ).thenAnswer((_) async => Success(createTestRecoveryVelocity()));

      final result = await repository.getFinancialPassport(
        asOf: now,
        windowDays: 30,
      );

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure,
        const DatabaseFailure(message: 'Low-level SQLite exception'),
      );
    });

    test(
      'catches unexpected Exception and converts to DatabaseFailure',
      () async {
        when(
          () => mockClosureRepository.getAllClosures(limit: 100),
        ).thenThrow(Exception('Crash'));
        when(
          () => mockClosureRepository.getActiveStreak(referenceDate: now),
        ).thenAnswer((_) async => const Success(0));
        when(
          () =>
              mockDebtRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
        ).thenAnswer((_) async => Success(createTestRecoveryVelocity()));

        final result = await repository.getFinancialPassport(
          asOf: now,
          windowDays: 30,
        );

        expect(result.isError, isTrue);
        expect((result as Error).failure.message, contains('Crash'));
      },
    );
  });
}
