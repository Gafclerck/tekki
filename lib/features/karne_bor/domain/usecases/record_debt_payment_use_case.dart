import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:uuid/uuid.dart';

/// Cas d'utilisation métier pour l'encaissement d'un remboursement (partiel ou total)
/// sur une dette client active.
class RecordDebtPaymentUseCase {
  const RecordDebtPaymentUseCase({
    required this.repository,
    this.uuid = const Uuid(),
  });

  final DebtRepository repository;
  final Uuid uuid;

  Future<Result<DebtPaymentEntity, Failure>> call({
    required DebtEntity debt,
    required int paymentAmount,
    String paymentMethod = 'ESPECES',
    DateTime? paidAt,
  }) async {
    if (paymentAmount <= 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant du remboursement doit être strictement positif.',
        ),
      );
    }

    if (paymentAmount > debt.remainingAmount) {
      return Error(
        ValidationFailure(
          message:
              'Le montant du remboursement ne peut pas dépasser le solde restant (${debt.remainingAmount} FCFA).',
        ),
      );
    }

    final newRemainingAmount = debt.remainingAmount - paymentAmount;
    final newStatus = newRemainingAmount == 0
        ? DebtStatus.settled
        : debt.status;

    final updatedDebt = debt.copyWith(
      remainingAmount: newRemainingAmount,
      status: newStatus,
    );

    final payment = DebtPaymentEntity(
      id: uuid.v4(),
      debtId: debt.id,
      paymentAmount: paymentAmount,
      paymentMethod: paymentMethod,
      paidAt: paidAt ?? DateTime.now().toUtc(),
    );

    return repository.recordDebtPayment(
      payment: payment,
      updatedDebt: updatedDebt,
    );
  }
}
