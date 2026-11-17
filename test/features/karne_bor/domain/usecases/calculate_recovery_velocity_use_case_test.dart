import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';

class MockDebtRepository extends Mock implements DebtRepository {}

void main() {
  late MockDebtRepository mockRepository;
  late CalculateRecoveryVelocityUseCase useCase;

  final now = DateTime.utc(2026, 11, 17, 12, 0);

  setUp(() {
    mockRepository = MockDebtRepository();
    useCase = CalculateRecoveryVelocityUseCase(repository: mockRepository);
  });

  group('CalculateRecoveryVelocityUseCase', () {
    group('call', () {
      test(
        'delegates to repository getRecoveryVelocity with asOf and windowDays',
        () async {
          const expectedVelocity = RecoveryVelocityEntity(
            rate: 85,
            totalDueAmount: 100000,
            totalRecoveredAmount: 85000,
            healthStatus:
                'Excellente santé financière : vos créances rentrent vite !',
            healthLevel: RecoveryHealthLevel.excellent,
          );

          when(
            () => mockRepository.getRecoveryVelocity(
              asOf: any(named: 'asOf'),
              windowDays: any(named: 'windowDays'),
            ),
          ).thenAnswer((_) async => const Success(expectedVelocity));

          final result = await useCase(asOf: now, windowDays: 30);

          expect(result.isSuccess, isTrue);
          expect(result, const Success(expectedVelocity));
          verify(
            () => mockRepository.getRecoveryVelocity(asOf: now, windowDays: 30),
          ).called(1);
        },
      );
    });

    group('calculatePure', () {
      test('carnet vierge (0 dette) returns 100% with benevolent status', () {
        final result = CalculateRecoveryVelocityUseCase.calculatePure(
          totalDueAmount: 0,
          totalRecoveredAmount: 0,
        );

        expect(result.rate, 100);
        expect(result.totalDueAmount, 0);
        expect(result.totalRecoveredAmount, 0);
        expect(result.healthLevel, RecoveryHealthLevel.excellent);
        expect(result.healthStatus, contains('aucun impayé'));
      });

      test(
        '80 000 F recovered on 100 000 F due yields 80% velocity and excellent health',
        () {
          final result = CalculateRecoveryVelocityUseCase.calculatePure(
            totalDueAmount: 100000,
            totalRecoveredAmount: 80000,
          );

          expect(result.rate, 80);
          expect(result.totalDueAmount, 100000);
          expect(result.totalRecoveredAmount, 80000);
          expect(result.healthLevel, RecoveryHealthLevel.excellent);
          expect(result.healthStatus, contains('Excellente santé financière'));
        },
      );

      test('100% impayés yields 0% velocity and critical health', () {
        final result = CalculateRecoveryVelocityUseCase.calculatePure(
          totalDueAmount: 100000,
          totalRecoveredAmount: 0,
        );

        expect(result.rate, 0);
        expect(result.healthLevel, RecoveryHealthLevel.critical);
        expect(result.healthStatus, contains('Attention requise'));
      });

      test('50% - 79% yields moderate health', () {
        final result = CalculateRecoveryVelocityUseCase.calculatePure(
          totalDueAmount: 100000,
          totalRecoveredAmount: 65000,
        );

        expect(result.rate, 65);
        expect(result.healthLevel, RecoveryHealthLevel.moderate);
        expect(result.healthStatus, contains('Santé financière modérée'));
      });
    });

    group('computeFromDebts', () {
      test(
        'computes velocity correctly on 30-day rolling window with payments',
        () {
          // Debt 1: 50 000 F due 5 days ago, paid 50 000 F 6 days ago (on time)
          final debt1 = DebtEntity(
            id: 'd1',
            debtorId: 'debtor1',
            initialAmount: 50000,
            remainingAmount: 0,
            dueDate: now.subtract(const Duration(days: 5)),
            status: DebtStatus.settled,
            createdAt: now.subtract(const Duration(days: 15)),
          );
          final payment1 = DebtPaymentEntity(
            id: 'p1',
            debtId: 'd1',
            paymentAmount: 50000,
            paidAt: now.subtract(const Duration(days: 6)), // Before dueDate!
          );

          // Debt 2: 50 000 F due 3 days ago, paid 30 000 F on time, 20 000 F overdue
          final debt2 = DebtEntity(
            id: 'd2',
            debtorId: 'debtor2',
            initialAmount: 50000,
            remainingAmount: 20000,
            dueDate: now.subtract(const Duration(days: 3)),
            status: DebtStatus.active,
            createdAt: now.subtract(const Duration(days: 10)),
          );
          final payment2 = DebtPaymentEntity(
            id: 'p2',
            debtId: 'd2',
            paymentAmount: 30000,
            paidAt: now.subtract(const Duration(days: 4)), // On time!
          );

          final result = CalculateRecoveryVelocityUseCase.computeFromDebts(
            debts: [debt1, debt2],
            paymentsByDebtId: {
              'd1': [payment1],
              'd2': [payment2],
            },
            asOf: now,
            windowDays: 30,
          );

          expect(result.totalDueAmount, 100000); // 50 000 + 50 000
          expect(result.totalRecoveredAmount, 80000); // 50 000 + 30 000
          expect(result.rate, 80);
        },
      );

      test(
        'payment made AFTER dueDate is excluded from on-time recovered amount',
        () {
          // Debt: 60 000 F due 10 days ago, payment made 2 days ago (late)
          final debt = DebtEntity(
            id: 'd-late',
            debtorId: 'debtor1',
            initialAmount: 60000,
            remainingAmount: 0,
            dueDate: now.subtract(const Duration(days: 10)),
            status: DebtStatus.settled,
            createdAt: now.subtract(const Duration(days: 20)),
          );
          final paymentLate = DebtPaymentEntity(
            id: 'p-late',
            debtId: 'd-late',
            paymentAmount: 60000,
            paidAt: now.subtract(
              const Duration(days: 2),
            ), // 8 days after dueDate!
          );

          final result = CalculateRecoveryVelocityUseCase.computeFromDebts(
            debts: [debt],
            paymentsByDebtId: {
              'd-late': [paymentLate],
            },
            asOf: now,
            windowDays: 30,
          );

          expect(result.totalDueAmount, 60000);
          expect(result.totalRecoveredAmount, 0); // Excluded because late
          expect(result.rate, 0);
        },
      );

      test('debts with dueDate outside the 30-day window are ignored', () {
        final oldDebt = DebtEntity(
          id: 'd-old',
          debtorId: 'debtor-old',
          initialAmount: 40000,
          remainingAmount: 40000,
          dueDate: now.subtract(const Duration(days: 60)), // 60 days ago
          status: DebtStatus.active,
          createdAt: now.subtract(const Duration(days: 70)),
        );

        final result = CalculateRecoveryVelocityUseCase.computeFromDebts(
          debts: [oldDebt],
          asOf: now,
          windowDays: 30,
        );

        // Outside window -> 0 due debts in window -> 100% velocity
        expect(result.totalDueAmount, 0);
        expect(result.rate, 100);
      });

      test('future active debt with no payments is not yet exigible', () {
        final futureDebt = DebtEntity(
          id: 'd-future',
          debtorId: 'debtor-f',
          initialAmount: 25000,
          remainingAmount: 25000,
          dueDate: now.add(const Duration(days: 10)), // 10 days in the future
          status: DebtStatus.active,
          createdAt: now.subtract(const Duration(days: 2)),
        );

        final result = CalculateRecoveryVelocityUseCase.computeFromDebts(
          debts: [futureDebt],
          asOf: now,
          windowDays: 30,
        );

        // Not yet exigible -> 100%
        expect(result.totalDueAmount, 0);
        expect(result.rate, 100);
      });
    });
  });
}
