import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_state.dart';

class MockGetClosurePrefillUseCase extends Mock
    implements GetClosurePrefillUseCase {}

class MockExecuteDailyClosureUseCase extends Mock
    implements ExecuteDailyClosureUseCase {}

class MockClosureRepository extends Mock implements ClosureRepository {}

class MockAudioPlayerService extends Mock implements IAudioPlayerService {}

void main() {
  late MockGetClosurePrefillUseCase mockPrefillUseCase;
  late MockExecuteDailyClosureUseCase mockExecuteUseCase;

  final fixedCutoff = DateTime(2026, 11, 17, 21, 0).toUtc();

  final testClosure = DailyClosureEntity(
    id: 'closure-cubit-test',
    shopId: 'shop-1',
    closureDate: '2026-11-17',
    cutoffTimestamp: fixedCutoff,
    totalSalesAmount: 17500,
    totalExpensesAmount: 2500,
    cashCounted: 15000,
  );

  setUp(() {
    mockPrefillUseCase = MockGetClosurePrefillUseCase();
    mockExecuteUseCase = MockExecuteDailyClosureUseCase();
  });

  group('ExpressClosureCubit', () {
    test('initial state freezes cutoffTimestamp in UTC and sets default amounts', () {
      final cubit = ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      );

      expect(cubit.state.cutoffTimestamp, equals(fixedCutoff));
      expect(cubit.state.cutoffTimestamp.isUtc, isTrue);
      expect(cubit.state.status, equals(ExpressClosureStatus.initial));
      expect(cubit.state.totalSalesAmount, equals(0));
      expect(cubit.state.totalExpensesAmount, equals(0));
      expect(cubit.state.cashCounted, equals(0));
      expect(cubit.state.currentStep, equals(1));
      expect(cubit.state.canSubmit, isFalse);

      cubit.close();
    });

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'init loads prefill and emits ready state with sales amount',
      build: () {
        when(() => mockPrefillUseCase(fixedCutoff)).thenAnswer(
          (_) async => const Success(17500),
        );
        return ExpressClosureCubit(
          getClosurePrefillUseCase: mockPrefillUseCase,
          executeDailyClosureUseCase: mockExecuteUseCase,
          initialCutoffTimestamp: fixedCutoff,
        );
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.loadingPrefill,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.ready,
          prefilledSalesAmount: 17500,
          totalSalesAmount: 17500,
        ),
      ],
      verify: (_) => verify(() => mockPrefillUseCase(fixedCutoff)).called(1),
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'init emits failure on prefill database error',
      build: () {
        when(() => mockPrefillUseCase(fixedCutoff)).thenAnswer(
          (_) async => const Error(DatabaseFailure(message: 'Query timeout')),
        );
        return ExpressClosureCubit(
          getClosurePrefillUseCase: mockPrefillUseCase,
          executeDailyClosureUseCase: mockExecuteUseCase,
          initialCutoffTimestamp: fixedCutoff,
        );
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.loadingPrefill,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.failure,
          errorMessage: 'Query timeout',
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'setStep updates currentStep',
      build: () => ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      ),
      act: (cubit) {
        cubit.setStep(2);
        cubit.setStep(3);
        cubit.setStep(4); // invalid step ignored
      },
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          currentStep: 2,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          currentStep: 3,
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'setTotalSales updates amount when positive or zero, rejects negative',
      build: () => ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      ),
      act: (cubit) {
        cubit.setTotalSales(108500);
        cubit.setTotalSales(-100);
      },
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 108500,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 108500,
          errorMessage: 'Le montant des ventes ne peut pas être négatif.',
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'setTotalExpenses updates amount when positive, rejects negative',
      build: () => ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      ),
      act: (cubit) {
        cubit.setTotalExpenses(15000);
        cubit.setTotalExpenses(-500);
      },
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalExpensesAmount: 15000,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalExpensesAmount: 15000,
          errorMessage: 'Le montant des dépenses ne peut pas être négatif.',
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'setCashCounted updates amount when positive, rejects negative',
      build: () => ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      ),
      act: (cubit) {
        cubit.setCashCounted(93500);
        cubit.setCashCounted(-10);
      },
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          cashCounted: 93500,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          cashCounted: 93500,
          errorMessage: 'Le montant des espèces ne peut pas être négatif.',
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'submitClosure succeeds and emits submitting then success',
      build: () {
        when(
          () => mockExecuteUseCase(
            cutoffTimestamp: fixedCutoff,
            totalSalesAmount: 17500,
            totalExpensesAmount: 2500,
            cashCounted: 15000,
            shopId: 'default-shop',
          ),
        ).thenAnswer((_) async => Success(testClosure));
        return ExpressClosureCubit(
          getClosurePrefillUseCase: mockPrefillUseCase,
          executeDailyClosureUseCase: mockExecuteUseCase,
          initialCutoffTimestamp: fixedCutoff,
        );
      },
      seed: () => ExpressClosureState(
        cutoffTimestamp: fixedCutoff,
        totalSalesAmount: 17500,
        totalExpensesAmount: 2500,
        cashCounted: 15000,
        status: ExpressClosureStatus.ready,
      ),
      act: (cubit) => cubit.submitClosure(),
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 17500,
          totalExpensesAmount: 2500,
          cashCounted: 15000,
          status: ExpressClosureStatus.submitting,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 17500,
          totalExpensesAmount: 2500,
          cashCounted: 15000,
          status: ExpressClosureStatus.success,
          createdClosure: testClosure,
        ),
      ],
    );

    blocTest<ExpressClosureCubit, ExpressClosureState>(
      'submitClosure fails and emits submitting then failure with error message',
      build: () {
        when(
          () => mockExecuteUseCase(
            cutoffTimestamp: fixedCutoff,
            totalSalesAmount: 10000,
            totalExpensesAmount: 0,
            cashCounted: 10000,
            shopId: 'default-shop',
          ),
        ).thenAnswer(
          (_) async =>
              const Error(DatabaseFailure(message: 'Disk write error')),
        );
        return ExpressClosureCubit(
          getClosurePrefillUseCase: mockPrefillUseCase,
          executeDailyClosureUseCase: mockExecuteUseCase,
          initialCutoffTimestamp: fixedCutoff,
        );
      },
      seed: () => ExpressClosureState(
        cutoffTimestamp: fixedCutoff,
        totalSalesAmount: 10000,
        totalExpensesAmount: 0,
        cashCounted: 10000,
        status: ExpressClosureStatus.ready,
      ),
      act: (cubit) => cubit.submitClosure(),
      expect: () => [
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 10000,
          totalExpensesAmount: 0,
          cashCounted: 10000,
          status: ExpressClosureStatus.submitting,
        ),
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 10000,
          totalExpensesAmount: 0,
          cashCounted: 10000,
          status: ExpressClosureStatus.failure,
          errorMessage: 'Disk write error',
        ),
      ],
    );

    test('canSubmit is only true when ready with no error message and valid amounts', () {
      final readyState = ExpressClosureState(
        cutoffTimestamp: fixedCutoff,
        status: ExpressClosureStatus.ready,
        totalSalesAmount: 1000,
      );
      expect(readyState.canSubmit, isTrue);

      expect(
        readyState.copyWith(status: ExpressClosureStatus.success).canSubmit,
        isFalse,
      );
      expect(
        readyState.copyWith(status: ExpressClosureStatus.failure).canSubmit,
        isFalse,
      );
      expect(
        readyState.copyWith(status: ExpressClosureStatus.submitting).canSubmit,
        isFalse,
      );
      expect(
        readyState.copyWith(errorMessage: 'Invalid amount').canSubmit,
        isFalse,
      );
      expect(
        readyState.copyWith(totalSalesAmount: -1).canSubmit,
        isFalse,
      );
    });

    test('reset reinitializes state to initial', () {
      final cubit = ExpressClosureCubit(
        getClosurePrefillUseCase: mockPrefillUseCase,
        executeDailyClosureUseCase: mockExecuteUseCase,
        initialCutoffTimestamp: fixedCutoff,
      );

      cubit.setTotalSales(5000);
      expect(cubit.state.totalSalesAmount, equals(5000));

      final newCutoff = DateTime(2026, 11, 18, 10, 0).toUtc();
      cubit.reset(newCutoff);

      expect(cubit.state.status, equals(ExpressClosureStatus.initial));
      expect(cubit.state.totalSalesAmount, equals(0));
      expect(cubit.state.cutoffTimestamp, equals(newCutoff));
      cubit.close();
    });

    group('Story 1.5 - Streak Loading on Init & Submit', () {
      late MockClosureRepository mockRepo;

      setUp(() {
        mockRepo = MockClosureRepository();
      });

      blocTest<ExpressClosureCubit, ExpressClosureState>(
        'init queries active streak and monthly count with shopId when repository is provided',
        build: () {
          when(() => mockPrefillUseCase(fixedCutoff)).thenAnswer(
            (_) async => const Success(25000),
          );
          when(() => mockRepo.getActiveStreak(referenceDate: fixedCutoff, shopId: 'shop-test')).thenAnswer(
            (_) async => const Success(5),
          );
          when(() => mockRepo.getMonthlyClosuresCount(fixedCutoff, shopId: 'shop-test')).thenAnswer(
            (_) async => const Success(12),
          );
          return ExpressClosureCubit(
            getClosurePrefillUseCase: mockPrefillUseCase,
            executeDailyClosureUseCase: mockExecuteUseCase,
            closureRepository: mockRepo,
            initialCutoffTimestamp: fixedCutoff,
          );
        },
        act: (cubit) => cubit.init(shopId: 'shop-test'),
        expect: () => [
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.loadingPrefill,
          ),
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.ready,
            prefilledSalesAmount: 25000,
            totalSalesAmount: 25000,
            activeStreak: 5,
            monthlyClosuresCount: 12,
          ),
        ],
        verify: (_) {
          verify(() => mockRepo.getActiveStreak(referenceDate: fixedCutoff, shopId: 'shop-test')).called(1);
          verify(() => mockRepo.getMonthlyClosuresCount(fixedCutoff, shopId: 'shop-test')).called(1);
        },
      );

      blocTest<ExpressClosureCubit, ExpressClosureState>(
        'submitClosure updates streak from repository',
        build: () {
          when(
            () => mockExecuteUseCase(
              cutoffTimestamp: fixedCutoff,
              totalSalesAmount: 25000,
              totalExpensesAmount: 0,
              cashCounted: 25000,
              shopId: 'default-shop',
            ),
          ).thenAnswer((_) async => Success(testClosure));
          when(() => mockRepo.getActiveStreak(referenceDate: fixedCutoff, shopId: 'default-shop')).thenAnswer(
            (_) async => const Success(6),
          );
          when(() => mockRepo.getMonthlyClosuresCount(fixedCutoff, shopId: 'default-shop')).thenAnswer(
            (_) async => const Success(13),
          );

          return ExpressClosureCubit(
            getClosurePrefillUseCase: mockPrefillUseCase,
            executeDailyClosureUseCase: mockExecuteUseCase,
            closureRepository: mockRepo,
            initialCutoffTimestamp: fixedCutoff,
          );
        },
        seed: () => ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 25000,
          cashCounted: 25000,
          status: ExpressClosureStatus.ready,
          activeStreak: 5,
          monthlyClosuresCount: 12,
        ),
        act: (cubit) => cubit.submitClosure(),
        expect: () => [
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            totalSalesAmount: 25000,
            cashCounted: 25000,
            status: ExpressClosureStatus.submitting,
            activeStreak: 5,
            monthlyClosuresCount: 12,
          ),
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            totalSalesAmount: 25000,
            cashCounted: 25000,
            status: ExpressClosureStatus.success,
            createdClosure: testClosure,
            activeStreak: 6,
            monthlyClosuresCount: 13,
          ),
        ],
      );
    });
  });
}
