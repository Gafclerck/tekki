import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_state.dart';

class CollectDebtPaymentCubit extends Cubit<CollectDebtPaymentState> {
  CollectDebtPaymentCubit({
    required DebtEntity debt,
    required this.recordDebtPaymentUseCase,
    this.audioPlayerService,
    this.hapticFeedbackCallback,
  }) : super(CollectDebtPaymentState(debt: debt));

  final RecordDebtPaymentUseCase recordDebtPaymentUseCase;
  final IAudioPlayerService? audioPlayerService;
  final VoidCallback? hapticFeedbackCallback;

  void selectFullPayment() {
    if (state.status == CollectDebtPaymentStatus.submitting) return;
    emit(state.copyWith(isFullPayment: true, clearErrorMessage: true));
  }

  void selectCustomPayment([int? initialAmount]) {
    if (state.status == CollectDebtPaymentStatus.submitting) return;
    final amount = initialAmount ?? state.customAmount;
    emit(
      state.copyWith(
        isFullPayment: false,
        customAmount: amount,
        clearErrorMessage: true,
      ),
    );
    if (amount > 0) {
      setCustomAmount(amount);
    }
  }

  void setCustomAmount(int amount) {
    if (state.status == CollectDebtPaymentStatus.submitting) return;

    if (amount < 0) {
      emit(
        state.copyWith(
          customAmount: 0,
          errorMessage: 'Le montant ne peut pas être négatif.',
        ),
      );
      return;
    }

    if (amount > state.debt.remainingAmount) {
      emit(
        state.copyWith(
          customAmount: amount,
          errorMessage:
              'Le montant ne peut pas dépasser le solde restant (${CurrencyFormatter.format(state.debt.remainingAmount)}).',
        ),
      );
      return;
    }

    emit(state.copyWith(customAmount: amount, clearErrorMessage: true));
  }

  Future<void> submitPayment() async {
    if (!state.canSubmit) return;

    emit(
      state.copyWith(
        status: CollectDebtPaymentStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final result = await recordDebtPaymentUseCase(
      debt: state.debt,
      paymentAmount: state.effectiveAmount,
      paymentMethod: 'ESPECES',
    );

    if (isClosed) return;

    result.fold(
      onSuccess: (payment) {
        // Trigger sensorial celebratory feedback with graceful degradation
        try {
          audioPlayerService?.playCashDrawerSound();
        } catch (_) {}

        try {
          if (hapticFeedbackCallback != null) {
            hapticFeedbackCallback!();
          } else {
            HapticFeedback.mediumImpact();
          }
        } catch (_) {}

        emit(
          state.copyWith(
            status: CollectDebtPaymentStatus.success,
            createdPayment: payment,
          ),
        );
      },
      onError: (failure) {
        emit(
          state.copyWith(
            status: CollectDebtPaymentStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }
}
