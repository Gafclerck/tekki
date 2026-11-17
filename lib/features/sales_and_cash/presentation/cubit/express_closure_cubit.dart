import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_state.dart';

class ExpressClosureCubit extends Cubit<ExpressClosureState> {
  ExpressClosureCubit({
    required this.getClosurePrefillUseCase,
    required this.executeDailyClosureUseCase,
    DateTime? initialCutoffTimestamp,
  }) : super(ExpressClosureState.initial(initialCutoffTimestamp));

  final GetClosurePrefillUseCase getClosurePrefillUseCase;
  final ExecuteDailyClosureUseCase executeDailyClosureUseCase;

  Future<void> init() async {
    if (state.status == ExpressClosureStatus.submitting ||
        state.status == ExpressClosureStatus.loadingPrefill) {
      return;
    }

    emit(state.copyWith(
      status: ExpressClosureStatus.loadingPrefill,
      clearErrorMessage: true,
    ));

    final result = await getClosurePrefillUseCase(state.cutoffTimestamp);
    if (isClosed) return;

    result.fold(
      onSuccess: (prefillAmount) {
        emit(state.copyWith(
          status: ExpressClosureStatus.ready,
          prefilledSalesAmount: prefillAmount,
          totalSalesAmount: prefillAmount,
          clearErrorMessage: true,
        ));
      },
      onError: (failure) {
        emit(state.copyWith(
          status: ExpressClosureStatus.failure,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void setStep(int step) {
    if (step >= 1 && step <= 3) {
      emit(state.copyWith(currentStep: step));
    }
  }

  void setTotalSales(int amount) {
    if (state.status == ExpressClosureStatus.submitting) return;
    if (amount < 0) {
      emit(state.copyWith(
        errorMessage: 'Le montant des ventes ne peut pas être négatif.',
      ));
      return;
    }
    emit(state.copyWith(
      totalSalesAmount: amount,
      clearErrorMessage: true,
    ));
  }

  void setTotalExpenses(int amount) {
    if (state.status == ExpressClosureStatus.submitting) return;
    if (amount < 0) {
      emit(state.copyWith(
        errorMessage: 'Le montant des dépenses ne peut pas être négatif.',
      ));
      return;
    }
    emit(state.copyWith(
      totalExpensesAmount: amount,
      clearErrorMessage: true,
    ));
  }

  void setCashCounted(int amount) {
    if (state.status == ExpressClosureStatus.submitting) return;
    if (amount < 0) {
      emit(state.copyWith(
        errorMessage: 'Le montant des espèces ne peut pas être négatif.',
      ));
      return;
    }
    emit(state.copyWith(
      cashCounted: amount,
      clearErrorMessage: true,
    ));
  }

  void reset([DateTime? newCutoff]) {
    emit(ExpressClosureState.initial(newCutoff));
  }

  Future<void> submitClosure({String shopId = 'default-shop'}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      status: ExpressClosureStatus.submitting,
      clearErrorMessage: true,
    ));

    final result = await executeDailyClosureUseCase(
      cutoffTimestamp: state.cutoffTimestamp,
      totalSalesAmount: state.totalSalesAmount,
      totalExpensesAmount: state.totalExpensesAmount,
      cashCounted: state.cashCounted,
      shopId: shopId,
    );
    if (isClosed) return;

    result.fold(
      onSuccess: (closure) {
        emit(state.copyWith(
          status: ExpressClosureStatus.success,
          createdClosure: closure,
        ));
      },
      onError: (failure) {
        emit(state.copyWith(
          status: ExpressClosureStatus.failure,
          errorMessage: failure.message,
        ));
      },
    );
  }
}
