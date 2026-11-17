import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';

class MockWatchActiveDebtsUseCase extends Mock
    implements WatchActiveDebtsUseCase {}

void main() {
  late MockWatchActiveDebtsUseCase mockWatchActiveDebtsUseCase;
  late KarneBorCubit cubit;
  late StreamController<List<DebtEntity>> streamController;

  final testDate = DateTime.utc(2026, 11, 17);

  setUp(() {
    mockWatchActiveDebtsUseCase = MockWatchActiveDebtsUseCase();
    streamController = StreamController<List<DebtEntity>>.broadcast();
    when(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')))
        .thenAnswer((_) => streamController.stream);

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
      'startWatching emits Loading then Loaded with calculated totalDebt',
      () async {
        final debts = [
          DebtEntity(
            id: 'debt-1',
            debtorId: 'debtor-1',
            initialAmount: 5000,
            remainingAmount: 5000,
            dueDate: testDate,
            createdAt: testDate,
          ),
          DebtEntity(
            id: 'debt-2',
            debtorId: 'debtor-2',
            initialAmount: 3000,
            remainingAmount: 2000, // partial remaining
            dueDate: testDate,
            createdAt: testDate,
          ),
        ];

        final expectedStates = [
          const KarneBorLoading(),
          KarneBorLoaded(debts: debts, totalDebt: 7000), // 5000 + 2000
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
