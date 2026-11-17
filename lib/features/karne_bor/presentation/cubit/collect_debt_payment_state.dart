import 'package:equatable/equatable.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';

enum CollectDebtPaymentStatus {
  initial,
  submitting,
  success,
  failure,
}

class CollectDebtPaymentState extends Equatable {
  const CollectDebtPaymentState({
    required this.debt,
    this.status = CollectDebtPaymentStatus.initial,
    this.isFullPayment = true,
    this.customAmount = 0,
    this.errorMessage,
    this.createdPayment,
  });

  final DebtEntity debt;
  final CollectDebtPaymentStatus status;
  final bool isFullPayment;
  final int customAmount;
  final String? errorMessage;
  final DebtPaymentEntity? createdPayment;

  int get effectiveAmount =>
      isFullPayment ? debt.remainingAmount : customAmount;

  int get remainingAfterPayment {
    final diff = debt.remainingAmount - effectiveAmount;
    return diff < 0 ? 0 : diff;
  }

  bool get canSubmit {
    if (status == CollectDebtPaymentStatus.submitting) return false;
    final amount = effectiveAmount;
    return amount > 0 && amount <= debt.remainingAmount;
  }

  CollectDebtPaymentState copyWith({
    DebtEntity? debt,
    CollectDebtPaymentStatus? status,
    bool? isFullPayment,
    int? customAmount,
    String? errorMessage,
    bool clearErrorMessage = false,
    DebtPaymentEntity? createdPayment,
  }) {
    return CollectDebtPaymentState(
      debt: debt ?? this.debt,
      status: status ?? this.status,
      isFullPayment: isFullPayment ?? this.isFullPayment,
      customAmount: customAmount ?? this.customAmount,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdPayment: createdPayment ?? this.createdPayment,
    );
  }

  @override
  List<Object?> get props => [
        debt,
        status,
        isFullPayment,
        customAmount,
        errorMessage,
        createdPayment,
      ];
}
