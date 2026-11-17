import 'dart:math';

import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/domain/repositories/advisor_repository.dart';
import 'package:tekki/features/advisor/domain/usecases/evaluate_financial_health_use_case.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';

/// Implémentation du repository du Conseiller Tekki.
///
/// Agrège les données locales de clôtures (`ClosureRepository`) et de dettes (`DebtRepository`)
/// sur une fenêtre glissante de 30 jours pour produire le diagnostic déterministe.
class AdvisorRepositoryImpl implements AdvisorRepository {
  const AdvisorRepositoryImpl({
    required this.closureRepository,
    required this.debtRepository,
  });

  final ClosureRepository closureRepository;
  final DebtRepository debtRepository;

  @override
  Future<Result<FinancialHealthEntity, Failure>> evaluateFinancialHealth({
    DateTime? asOf,
    int windowDays = 30,
  }) async {
    try {
      final queryLimit = max(100, windowDays * 2);

      final results = await Future.wait([
        closureRepository.getAllClosures(limit: queryLimit),
        debtRepository.getActiveDebts(),
        debtRepository.getRecoveryVelocity(asOf: asOf, windowDays: windowDays),
      ]);

      final closuresResult =
          results[0] as Result<List<DailyClosureEntity>, Failure>;
      final debtsResult = results[1] as Result<List<DebtEntity>, Failure>;
      final velocityResult =
          results[2] as Result<RecoveryVelocityEntity, Failure>;

      if (closuresResult is Error<List<DailyClosureEntity>, Failure>) {
        return Error(closuresResult.failure);
      }
      if (debtsResult is Error<List<DebtEntity>, Failure>) {
        return Error(debtsResult.failure);
      }
      if (velocityResult is Error<RecoveryVelocityEntity, Failure>) {
        return Error(velocityResult.failure);
      }

      final closures =
          (closuresResult as Success<List<DailyClosureEntity>, Failure>).data;
      final debts = (debtsResult as Success<List<DebtEntity>, Failure>).data;
      final velocity =
          (velocityResult as Success<RecoveryVelocityEntity, Failure>).data;

      final health = EvaluateFinancialHealthUseCase.computeFromData(
        closures: closures,
        debts: debts,
        recoveryVelocity: velocity,
        asOf: asOf,
        windowDays: windowDays,
      );

      return Success(health);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Erreur inattendue : $e'));
    }
  }
}
