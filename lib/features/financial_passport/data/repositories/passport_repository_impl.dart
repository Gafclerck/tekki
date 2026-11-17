import 'dart:math';

import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';

/// Implémentation du repository de Passeport Financier.
///
/// Agrège les données locales de clôtures (`ClosureRepository`) et de dettes (`DebtRepository`)
/// sur une fenêtre glissante de 30 jours pour calculer le score in-app.
class PassportRepositoryImpl implements PassportRepository {
  const PassportRepositoryImpl({
    required this.closureRepository,
    required this.debtRepository,
  });

  final ClosureRepository closureRepository;
  final DebtRepository debtRepository;

  @override
  Future<Result<FinancialPassportEntity, Failure>> getFinancialPassport({
    DateTime? asOf,
    int windowDays = 30,
  }) async {
    try {
      final queryLimit = max(100, windowDays * 2);

      final results = await Future.wait([
        closureRepository.getAllClosures(limit: queryLimit),
        closureRepository.getActiveStreak(referenceDate: asOf),
        debtRepository.getRecoveryVelocity(asOf: asOf, windowDays: windowDays),
      ]);

      final closuresResult =
          results[0] as Result<List<DailyClosureEntity>, Failure>;
      final streakResult = results[1] as Result<int, Failure>;
      final velocityResult =
          results[2] as Result<RecoveryVelocityEntity, Failure>;

      if (closuresResult is Error<List<DailyClosureEntity>, Failure>) {
        return Error(closuresResult.failure);
      }
      if (streakResult is Error<int, Failure>) {
        return Error(streakResult.failure);
      }
      if (velocityResult is Error<RecoveryVelocityEntity, Failure>) {
        return Error(velocityResult.failure);
      }

      final closures =
          (closuresResult as Success<List<DailyClosureEntity>, Failure>).data;
      final streak = (streakResult as Success<int, Failure>).data;
      final velocity =
          (velocityResult as Success<RecoveryVelocityEntity, Failure>).data;

      final passport = CalculateFinancialPassportUseCase.computeFromData(
        closures: closures,
        recoveryVelocity: velocity,
        streak: streak,
        asOf: asOf,
        windowDays: windowDays,
      );

      return Success(passport);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Erreur inattendue : $e'));
    }
  }
}
