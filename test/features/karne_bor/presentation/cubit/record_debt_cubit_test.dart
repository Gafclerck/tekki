import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_state.dart';

class MockRecordDebtUseCase extends Mock implements RecordDebtUseCase {}

class MockGetDebtorsUseCase extends Mock implements GetDebtorsUseCase {}

class FakeRecordDebtParams extends Fake implements RecordDebtParams {}

void main() {
  late MockRecordDebtUseCase mockRecordDebtUseCase;
  late MockGetDebtorsUseCase mockGetDebtorsUseCase;
  late RecordDebtCubit cubit;

  final testDate = DateTime.utc(2026, 11, 17);

  setUpAll(() {
    registerFallbackValue(FakeRecordDebtParams());
  });

  setUp(() {
    mockRecordDebtUseCase = MockRecordDebtUseCase();
    mockGetDebtorsUseCase = MockGetDebtorsUseCase();
    cubit = RecordDebtCubit(
      recordDebtUseCase: mockRecordDebtUseCase,
      getDebtorsUseCase: mockGetDebtorsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('RecordDebtCubit', () {
    test('initial state is RecordDebtInitial with empty list', () {
      expect(cubit.state, const RecordDebtInitial(knownDebtors: []));
    });

    test('loadDebtors updates RecordDebtInitial with debtors', () async {
      final debtors = [
        DebtorEntity(id: 'd-1', name: 'Fatou', createdAt: testDate),
      ];
      when(
        () => mockGetDebtorsUseCase.call(),
      ).thenAnswer((_) async => Success(debtors));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([RecordDebtInitial(knownDebtors: debtors)]),
      );

      await cubit.loadDebtors();
      await expectation;
    });

    test(
      'submit emits Submitting then Success on successful creation',
      () async {
        final debt = DebtEntity(
          id: 'debt-1',
          debtorId: 'debtor-1',
          initialAmount: 5000,
          remainingAmount: 5000,
          dueDate: testDate.add(const Duration(days: 7)),
          createdAt: testDate,
        );

        when(
          () => mockRecordDebtUseCase.call(any()),
        ).thenAnswer((_) async => Success(debt));

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            const RecordDebtSubmitting(),
            RecordDebtSuccess(debt: debt),
          ]),
        );

        await cubit.submit(debtorName: 'Fatou Kiné', amount: 5000);
        await expectation;
      },
    );

    test('submit emits Submitting then Failure on error', () async {
      when(() => mockRecordDebtUseCase.call(any())).thenAnswer(
        (_) async => const Error(
          ValidationFailure(message: 'Le montant doit être supérieur à zéro.'),
        ),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const RecordDebtSubmitting(),
          const RecordDebtFailure(
            message: 'Le montant doit être supérieur à zéro.',
          ),
        ]),
      );

      await cubit.submit(debtorName: 'Fatou Kiné', amount: 0);
      await expectation;
    });
  });
}
