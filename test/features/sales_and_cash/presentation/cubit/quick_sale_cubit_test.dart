import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_state.dart';

class MockRecordQuickSaleUseCase extends Mock
    implements RecordQuickSaleUseCase {}

void main() {
  late MockRecordQuickSaleUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockRecordQuickSaleUseCase();
  });

  final testSale = SaleEntity(
    id: 'sale-1',
    amount: 5000,
    paymentMethod: PaymentMethod.especes,
    recordedAt: DateTime(2026, 11, 17, 8, 0),
  );

  group('QuickSaleCubit', () {
    test('initial state is correct', () {
      final cubit = QuickSaleCubit(recordQuickSaleUseCase: mockUseCase);
      expect(cubit.state.amount, equals(0));
      expect(cubit.state.paymentMethod, equals(PaymentMethod.especes));
      expect(cubit.state.status, equals(QuickSaleStatus.initial));
      expect(cubit.state.canSubmit, isFalse);
      cubit.close();
    });

    blocTest<QuickSaleCubit, QuickSaleState>(
      'appendDigit constructs amount and sets canSubmit to true',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      act: (cubit) {
        cubit.appendDigit(5);
        cubit.appendDigit(0);
        cubit.appendDigit(0);
        cubit.appendDigit(0);
      },
      expect: () => [
        const QuickSaleState(amount: 5),
        const QuickSaleState(amount: 50),
        const QuickSaleState(amount: 500),
        const QuickSaleState(amount: 5000),
      ],
      verify: (cubit) => expect(cubit.state.canSubmit, isTrue),
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'appendDigit ignores leading zero when amount is 0',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      act: (cubit) {
        cubit.appendDigit(0);
      },
      expect: () => <QuickSaleState>[],
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'appendDigit caps amount to 9 digits',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      seed: () => const QuickSaleState(amount: 999999999),
      act: (cubit) {
        cubit.appendDigit(5);
      },
      expect: () => <QuickSaleState>[],
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'deleteDigit decrements digits and resets to 0',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      seed: () => const QuickSaleState(amount: 250),
      act: (cubit) {
        cubit.deleteDigit();
        cubit.deleteDigit();
        cubit.deleteDigit();
      },
      expect: () => [
        const QuickSaleState(amount: 25),
        const QuickSaleState(amount: 2),
        const QuickSaleState(amount: 0),
      ],
      verify: (cubit) => expect(cubit.state.canSubmit, isFalse),
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'clear resets amount to 0',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      seed: () => const QuickSaleState(amount: 7500),
      act: (cubit) => cubit.clear(),
      expect: () => [
        const QuickSaleState(amount: 0),
      ],
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'setPaymentMethod updates paymentMethod',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      act: (cubit) => cubit.setPaymentMethod(PaymentMethod.mobileMoney),
      expect: () => [
        const QuickSaleState(paymentMethod: PaymentMethod.mobileMoney),
      ],
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'submit succeeds and emits submitting then success',
      build: () {
        when(
          () => mockUseCase(
            amount: 5000,
            paymentMethod: PaymentMethod.especes,
          ),
        ).thenAnswer((_) async => Success(testSale));
        return QuickSaleCubit(recordQuickSaleUseCase: mockUseCase);
      },
      seed: () => const QuickSaleState(amount: 5000),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const QuickSaleState(
          amount: 5000,
          status: QuickSaleStatus.submitting,
        ),
        QuickSaleState(
          amount: 5000,
          status: QuickSaleStatus.success,
          createdSale: testSale,
        ),
      ],
      verify: (_) {
        verify(
          () => mockUseCase(
            amount: 5000,
            paymentMethod: PaymentMethod.especes,
          ),
        ).called(1);
      },
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'submit fails and emits submitting then failure with message',
      build: () {
        when(
          () => mockUseCase(
            amount: 5000,
            paymentMethod: PaymentMethod.especes,
          ),
        ).thenAnswer(
          (_) async => const Error(DatabaseFailure(message: 'Database write error')),
        );
        return QuickSaleCubit(recordQuickSaleUseCase: mockUseCase);
      },
      seed: () => const QuickSaleState(amount: 5000),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const QuickSaleState(
          amount: 5000,
          status: QuickSaleStatus.submitting,
        ),
        const QuickSaleState(
          amount: 5000,
          status: QuickSaleStatus.failure,
          errorMessage: 'Database write error',
        ),
      ],
    );

    blocTest<QuickSaleCubit, QuickSaleState>(
      'submit does nothing when amount is 0',
      build: () => QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
      act: (cubit) => cubit.submit(),
      expect: () => <QuickSaleState>[],
      verify: (_) => verifyZeroInteractions(mockUseCase),
    );
  });
}
