import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';

class MockWatchActiveDebtsUseCase extends Mock
    implements WatchActiveDebtsUseCase {}

class MockCalculateRecoveryVelocityUseCase extends Mock
    implements CalculateRecoveryVelocityUseCase {}

void main() {
  late MockWatchActiveDebtsUseCase mockWatchActiveDebtsUseCase;
  late MockCalculateRecoveryVelocityUseCase
  mockCalculateRecoveryVelocityUseCase;
  late KarneBorCubit cubit;
  late StreamController<List<DebtEntity>> streamController;

  final now = DateTime.now().toUtc();
  final testDate = DateTime.utc(2026, 11, 17);

  setUp(() {
    mockWatchActiveDebtsUseCase = MockWatchActiveDebtsUseCase();
    mockCalculateRecoveryVelocityUseCase =
        MockCalculateRecoveryVelocityUseCase();
    streamController = StreamController<List<DebtEntity>>.broadcast();
    when(
      () => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')),
    ).thenAnswer((_) => streamController.stream);

    cubit = KarneBorCubit(watchActiveDebtsUseCase: mockWatchActiveDebtsUseCase);
  });

  tearDown(() {
    streamController.close();
    cubit.close();
  });

  group('KarneBorCubit', () {
    test('initial state is KarneBorInitial', () {
      expect(cubit.state, const KarneBorInitial());
    });

    test(
      'startWatching emits Loading then Loaded with calculated totalDebt and overdueCount',
      () async {
        final debts = [
          DebtEntity(
            id: 'debt-1',
            debtorId: 'debtor-1',
            initialAmount: 5000,
            remainingAmount: 5000,
            dueDate: now.add(const Duration(days: 3)),
            createdAt: testDate,
          ),
          DebtEntity(
            id: 'debt-2',
            debtorId: 'debtor-2',
            initialAmount: 3000,
            remainingAmount: 2000, // partial remaining
            dueDate: now.add(const Duration(days: 5)),
            createdAt: testDate,
          ),
        ];

        final expectedStates = [
          const KarneBorLoading(),
          KarneBorLoaded(
            debts: debts,
            totalDebt: 7000, // 5000 + 2000
            overdueCount: 0,
          ),
        ];

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        cubit.startWatching();
        streamController.add(debts);
        await expectation;
      },
    );

    test(
      'sorts debts by urgency: overdue first by oldest dueDate, then upcoming by closest dueDate',
      () async {
        // 2 overdue debts:
        // overdue-oldest: due 10 days ago
        final overdueOldest = DebtEntity(
          id: 'overdue-oldest',
          debtorId: 'd-1',
          initialAmount: 10000,
          remainingAmount: 10000,
          dueDate: now.subtract(const Duration(days: 10)),
          status: DebtStatus.active,
          createdAt: testDate,
        );
        // overdue-recent: due 2 days ago
        final overdueRecent = DebtEntity(
          id: 'overdue-recent',
          debtorId: 'd-2',
          initialAmount: 5000,
          remainingAmount: 5000,
          dueDate: now.subtract(const Duration(days: 2)),
          status: DebtStatus.active,
          createdAt: testDate,
        );

        // 2 upcoming debts:
        // upcoming-soon: due in 2 days
        final upcomingSoon = DebtEntity(
          id: 'upcoming-soon',
          debtorId: 'd-3',
          initialAmount: 15000,
          remainingAmount: 15000,
          dueDate: now.add(const Duration(days: 2)),
          status: DebtStatus.active,
          createdAt: testDate,
        );
        // upcoming-far: due in 15 days
        final upcomingFar = DebtEntity(
          id: 'upcoming-far',
          debtorId: 'd-4',
          initialAmount: 8000,
          remainingAmount: 8000,
          dueDate: now.add(const Duration(days: 15)),
          status: DebtStatus.active,
          createdAt: testDate,
        );

        // Pass them in shuffled order
        final unsorted = [
          upcomingFar,
          overdueRecent,
          upcomingSoon,
          overdueOldest,
        ];

        cubit.startWatching();
        streamController.add(unsorted);

        await expectLater(
          cubit.stream,
          emitsThrough(
            predicate<KarneBorState>((state) {
              if (state is! KarneBorLoaded) return false;
              expect(state.totalDebt, 38000); // 10000 + 5000 + 15000 + 8000
              expect(state.overdueCount, 2);
              expect(state.hasOverdue, isTrue);

              // Expected order: overdueOldest, overdueRecent, upcomingSoon, upcomingFar
              final ids = state.debts.map((d) => d.id).toList();
              expect(ids, [
                'overdue-oldest',
                'overdue-recent',
                'upcoming-soon',
                'upcoming-far',
              ]);
              return true;
            }),
          ),
        );
      },
    );

    test('counts debt with status OVERDUE as overdue', () async {
      final overdueByStatus = DebtEntity(
        id: 'debt-explicit-overdue',
        debtorId: 'd-x',
        initialAmount: 6000,
        remainingAmount: 6000,
        dueDate: now.add(
          const Duration(days: 1),
        ), // future due date but OVERDUE status
        status: DebtStatus.overdue,
        createdAt: testDate,
      );

      cubit.startWatching();
      streamController.add([overdueByStatus]);

      await expectLater(
        cubit.stream,
        emitsThrough(
          predicate<KarneBorState>((state) {
            if (state is! KarneBorLoaded) return false;
            expect(state.totalDebt, 6000);
            expect(state.overdueCount, 1);
            expect(state.hasOverdue, isTrue);
            expect(state.debts.first.isOverdue, isTrue);
            return true;
          }),
        ),
      );
    });

    test('handles empty debts correctly', () async {
      cubit.startWatching();
      streamController.add([]);

      await expectLater(
        cubit.stream,
        emitsThrough(
          predicate<KarneBorState>((state) {
            if (state is! KarneBorLoaded) return false;
            expect(state.totalDebt, 0);
            expect(state.overdueCount, 0);
            expect(state.hasOverdue, isFalse);
            expect(state.isEmpty, isTrue);
            return true;
          }),
        ),
      );
    });

    test(
      'emits KarneBorLoaded with calculated recoveryVelocity when CalculateRecoveryVelocityUseCase is provided',
      () async {
        const expectedVelocity = RecoveryVelocityEntity(
          rate: 80,
          totalDueAmount: 100000,
          totalRecoveredAmount: 80000,
          healthStatus:
              'Excellente santé financière : vos créances rentrent vite !',
          healthLevel: RecoveryHealthLevel.excellent,
        );

        when(
          () => mockCalculateRecoveryVelocityUseCase.call(),
        ).thenAnswer((_) async => const Success(expectedVelocity));

        final cubitWithVelocity = KarneBorCubit(
          watchActiveDebtsUseCase: mockWatchActiveDebtsUseCase,
          calculateRecoveryVelocityUseCase:
              mockCalculateRecoveryVelocityUseCase,
        );

        final expectation = expectLater(
          cubitWithVelocity.stream,
          emitsThrough(
            predicate<KarneBorState>((state) {
              if (state is! KarneBorLoaded) return false;
              expect(state.recoveryRate, 80);
              expect(state.recoveryVelocity, expectedVelocity);
              return true;
            }),
          ),
        );

        cubitWithVelocity.startWatching();
        streamController.add([]);

        await expectation;
        await cubitWithVelocity.close();
      },
    );

    test('startWatching emits Error on stream error', () async {
      final expectedStates = [
        const KarneBorLoading(),
        predicate<KarneBorState>(
          (s) => s is KarneBorError && s.message.contains('Database failure'),
        ),
      ];

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      cubit.startWatching();
      streamController.addError(Exception('Database failure'));
      await expectation;
    });
  });
}
