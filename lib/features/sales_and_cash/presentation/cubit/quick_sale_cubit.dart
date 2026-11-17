import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_state.dart';

class QuickSaleCubit extends Cubit<QuickSaleState> {
  QuickSaleCubit({required this.recordQuickSaleUseCase})
    : super(const QuickSaleState());

  final RecordQuickSaleUseCase recordQuickSaleUseCase;

  void appendDigit(int digit) {
    if (state.status == QuickSaleStatus.submitting) return;
    if (digit < 0 || digit > 9) return;

    if (state.amount == 0 && digit == 0) return;

    final newAmountString = state.amount == 0
        ? '$digit'
        : '${state.amount}$digit';
    if (newAmountString.length > 9) return;

    final newAmount = int.tryParse(newAmountString);
    if (newAmount != null) {
      emit(
        state.copyWith(
          amount: newAmount,
          status: QuickSaleStatus.initial,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void deleteDigit() {
    if (state.status == QuickSaleStatus.submitting) return;
    if (state.amount <= 0) return;

    final amountString = state.amount.toString();
    if (amountString.length <= 1) {
      emit(
        state.copyWith(
          amount: 0,
          status: QuickSaleStatus.initial,
          clearErrorMessage: true,
        ),
      );
    } else {
      final newAmount = int.parse(
        amountString.substring(0, amountString.length - 1),
      );
      emit(
        state.copyWith(
          amount: newAmount,
          status: QuickSaleStatus.initial,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void clear() {
    if (state.status == QuickSaleStatus.submitting) return;
    emit(
      state.copyWith(
        amount: 0,
        status: QuickSaleStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    if (state.status == QuickSaleStatus.submitting) return;
    emit(state.copyWith(paymentMethod: method, clearErrorMessage: true));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(
      state.copyWith(
        status: QuickSaleStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final result = await recordQuickSaleUseCase(
      amount: state.amount,
      paymentMethod: state.paymentMethod,
    );

    result.fold(
      onSuccess: (sale) {
        emit(
          state.copyWith(status: QuickSaleStatus.success, createdSale: sale),
        );
      },
      onError: (failure) {
        emit(
          state.copyWith(
            status: QuickSaleStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }
}
