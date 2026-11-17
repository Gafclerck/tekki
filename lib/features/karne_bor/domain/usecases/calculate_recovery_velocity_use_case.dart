import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';

/// Cas d'utilisation pur Dart calculant la vélocité de recouvrement sur une fenêtre glissante (30 jours).
///
/// Formule :
/// Vélocité = 100% si aucune créance exigible
///          = round((Montant recouvré dans les délais / Montant total exigible) * 100) sinon
/// Résultat borné entre 0 et 100%.
class CalculateRecoveryVelocityUseCase {
  const CalculateRecoveryVelocityUseCase({required this.repository});

  final DebtRepository repository;

  Future<Result<RecoveryVelocityEntity, Failure>> call({
    DateTime? asOf,
    int windowDays = 30,
  }) {
    return repository.getRecoveryVelocity(asOf: asOf, windowDays: windowDays);
  }

  /// Calcul pur Dart de la vélocité à partir d'une liste de créances et de leurs paiements éventuels.
  static RecoveryVelocityEntity computeFromDebts({
    required List<DebtEntity> debts,
    Map<String, List<DebtPaymentEntity>>? paymentsByDebtId,
    DateTime? asOf,
    int windowDays = 30,
  }) {
    final referenceDate = (asOf ?? DateTime.now()).toUtc();
    final windowStart = referenceDate.subtract(Duration(days: windowDays));

    int totalDue = 0;
    int totalRecovered = 0;

    for (final debt in debts) {
      final endOfDueDate = DateTime.utc(
        debt.dueDate.year,
        debt.dueDate.month,
        debt.dueDate.day,
        23,
        59,
        59,
        999,
      );

      // Une créance est dans la fenêtre si son échéance ou sa date de création est >= windowStart
      final isInWindow =
          endOfDueDate.isAfter(windowStart) ||
          endOfDueDate.isAtSameMomentAs(windowStart) ||
          debt.createdAt.isAfter(windowStart) ||
          debt.createdAt.isAtSameMomentAs(windowStart);

      if (!isInWindow) {
        continue;
      }

      // Une créance est exigible si son échéance est échue/arrivée à la date de référence, ou si elle a été soldée
      final isDueOrOverdue =
          endOfDueDate.isBefore(referenceDate) ||
          endOfDueDate.isAtSameMomentAs(referenceDate);
      final isSettled = debt.status == DebtStatus.settled;

      final isExigible = isDueOrOverdue || isSettled;

      if (!isExigible) {
        // Créance future non encore échue et non soldée : n'est pas encore exigible
        continue;
      }

      totalDue += debt.initialAmount;

      // Calcul du montant recouvré dans les délais
      if (paymentsByDebtId != null) {
        final payments = paymentsByDebtId[debt.id] ?? const [];
        int debtRecoveredOnTime = 0;
        for (final p in payments) {
          // Paiement dans les délais : paidAt <= endOfDueDate
          if (p.paidAt.isBefore(endOfDueDate) ||
              p.paidAt.isAtSameMomentAs(endOfDueDate)) {
            debtRecoveredOnTime += p.paymentAmount;
          }
        }
        totalRecovered += debtRecoveredOnTime.clamp(0, debt.initialAmount);
      } else {
        // En l'absence de table détaillée de paiements (ex: fixtures de test unitaires simplifiées)
        if (isSettled && !debt.isOverdue) {
          totalRecovered += debt.initialAmount;
        } else if (!debt.isOverdue) {
          final paid = debt.initialAmount - debt.remainingAmount;
          totalRecovered += paid.clamp(0, debt.initialAmount);
        } else if (debt.isOverdue) {
          final paid = debt.initialAmount - debt.remainingAmount;
          totalRecovered += paid.clamp(0, debt.initialAmount);
        }
      }
    }

    return calculatePure(
      totalDueAmount: totalDue,
      totalRecoveredAmount: totalRecovered,
      windowDays: windowDays,
    );
  }

  /// Calcul mathématique direct déterministe avec diagnostic de santé financière
  static RecoveryVelocityEntity calculatePure({
    required int totalDueAmount,
    required int totalRecoveredAmount,
    int windowDays = 30,
  }) {
    if (totalDueAmount <= 0) {
      return RecoveryVelocityEntity(
        rate: 100,
        totalDueAmount: 0,
        totalRecoveredAmount: 0,
        healthStatus:
            'Excellente santé financière : aucun impayé sur les $windowDays derniers jours !',
        healthLevel: RecoveryHealthLevel.excellent,
        windowDays: windowDays,
      );
    }

    final safeRecovered = totalRecoveredAmount.clamp(0, totalDueAmount);
    final calculatedRate = ((safeRecovered / totalDueAmount) * 100)
        .round()
        .clamp(0, 100);

    final RecoveryHealthLevel healthLevel;
    final String healthStatus;

    if (calculatedRate >= 80) {
      healthLevel = RecoveryHealthLevel.excellent;
      healthStatus =
          'Excellente santé financière : vos créances rentrent vite !';
    } else if (calculatedRate >= 50) {
      healthLevel = RecoveryHealthLevel.moderate;
      healthStatus =
          'Santé financière modérée : pensez à relancer les retards.';
    } else {
      healthLevel = RecoveryHealthLevel.critical;
      healthStatus = 'Attention requise : accélérez vos relances clients.';
    }

    return RecoveryVelocityEntity(
      rate: calculatedRate,
      totalDueAmount: totalDueAmount,
      totalRecoveredAmount: safeRecovered,
      healthStatus: healthStatus,
      healthLevel: healthLevel,
      windowDays: windowDays,
    );
  }
}
