import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_state.dart';

class ExpressClosureCubit extends Cubit<ExpressClosureState> {
  ExpressClosureCubit({
    required this.getClosurePrefillUseCase,
    required this.executeDailyClosureUseCase,
    this.closureRepository,
    this.audioPlayerService,
    DateTime? initialCutoffTimestamp,
  }) : super(ExpressClosureState.initial(initialCutoffTimestamp));

  final GetClosurePrefillUseCase getClosurePrefillUseCase;
  final ExecuteDailyClosureUseCase executeDailyClosureUseCase;
  final ClosureRepository? closureRepository;
  final IAudioPlayerService? audioPlayerService;

  Future<void> init({String shopId = 'default-shop'}) async {
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

    if (result.isError) {
      final failure = (result as Error<int, Failure>).failure;
      emit(state.copyWith(
        status: ExpressClosureStatus.failure,
        errorMessage: failure.message,
      ));
      return;
    }

    final prefillAmount = (result as Success<int, Failure>).data;
    int streak = state.activeStreak;
    int monthlyCount = state.monthlyClosuresCount;
    int debtInflow = 0;

    if (closureRepository != null) {
      final debtInflowResult = await closureRepository!.getPrefillDebtCashInflow(
        state.cutoffTimestamp,
      );
      debtInflowResult.fold(
        onSuccess: (d) => debtInflow = d,
        onError: (_) {},
      );

      final streakResult = await closureRepository!.getActiveStreak(
        referenceDate: state.cutoffTimestamp,
        shopId: shopId,
      );
      streakResult.fold(
        onSuccess: (s) => streak = s,
        onError: (_) {},
      );

      final monthlyResult = await closureRepository!.getMonthlyClosuresCount(
        state.cutoffTimestamp,
        shopId: shopId,
      );
      monthlyResult.fold(
        onSuccess: (m) => monthlyCount = m,
        onError: (_) {},
      );
    }

    if (isClosed) return;
    emit(state.copyWith(
      status: ExpressClosureStatus.ready,
      prefilledSalesAmount: prefillAmount,
      totalSalesAmount: prefillAmount,
      totalCashDebtInflow: debtInflow,
      activeStreak: streak,
      monthlyClosuresCount: monthlyCount,
      clearErrorMessage: true,
    ));
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
      totalCashDebtInflow: state.totalCashDebtInflow,
      shopId: shopId,
    );
    if (isClosed) return;

    if (result.isSuccess) {
      final closure = (result as Success<DailyClosureEntity, Failure>).data;

      int updatedStreak = state.activeStreak;
      int updatedMonthly = state.monthlyClosuresCount;

      if (closureRepository != null) {
        final streakResult = await closureRepository!.getActiveStreak(
          referenceDate: state.cutoffTimestamp,
          shopId: shopId,
        );
        streakResult.fold(
          onSuccess: (s) => updatedStreak = s,
          onError: (_) {},
        );

        final monthlyResult = await closureRepository!.getMonthlyClosuresCount(
          state.cutoffTimestamp,
          shopId: shopId,
        );
        monthlyResult.fold(
          onSuccess: (m) => updatedMonthly = m,
          onError: (_) {},
        );
      }

      if (isClosed) return;
      emit(state.copyWith(
        status: ExpressClosureStatus.success,
        createdClosure: closure,
        activeStreak: updatedStreak,
        monthlyClosuresCount: updatedMonthly,
      ));
    } else {
      final failure = (result as Error<DailyClosureEntity, Failure>).failure;
      emit(state.copyWith(
        status: ExpressClosureStatus.failure,
        errorMessage: failure.message,
      ));
    }
  }
}
