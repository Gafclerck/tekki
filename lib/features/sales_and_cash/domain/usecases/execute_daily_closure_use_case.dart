import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:uuid/uuid.dart';

class ExecuteDailyClosureUseCase {
  const ExecuteDailyClosureUseCase({
    required this.repository,
    this.uuid = const Uuid(),
  });

  final ClosureRepository repository;
  final Uuid uuid;

  Future<Result<DailyClosureEntity, Failure>> call({
    required DateTime cutoffTimestamp,
    required int totalSalesAmount,
    int totalExpensesAmount = 0,
    int cashCounted = 0,
    int totalCashDebtInflow = 0,
    int totalCreditSalesAmount = 0,
    String shopId = 'default-shop',
    String? closureDate,
    double? gpsLatitude,
    double? gpsLongitude,
    double? distanceMeters,
    bool isFlaggedLocation = false,
  }) async {
    if (totalSalesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant total des ventes ne peut pas être négatif.',
        ),
      );
    }
    if (totalExpensesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant des dépenses ne peut pas être négatif.',
        ),
      );
    }
    if (cashCounted < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant des espèces comptées ne peut pas être négatif.',
        ),
      );
    }
    if (totalCashDebtInflow < 0) {
      return const Error(
        ValidationFailure(
          message: 'Les remboursements de dettes ne peuvent pas être négatifs.',
        ),
      );
    }
    if (totalCreditSalesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Les ventes à crédit ne peuvent pas être négatives.',
        ),
      );
    }

    final utcCutoff = cutoffTimestamp.toUtc();
    final dateStr = closureDate ??
        '${utcCutoff.year.toString().padLeft(4, '0')}-${utcCutoff.month.toString().padLeft(2, '0')}-${utcCutoff.day.toString().padLeft(2, '0')}';

    try {
      final closure = DailyClosureEntity(
        id: uuid.v4(),
        shopId: shopId,
        closureDate: dateStr,
        cutoffTimestamp: utcCutoff,
        totalSalesAmount: totalSalesAmount,
        totalExpensesAmount: totalExpensesAmount,
        cashCounted: cashCounted,
        totalCashDebtInflow: totalCashDebtInflow,
        totalCreditSalesAmount: totalCreditSalesAmount,
        gpsLatitude: gpsLatitude,
        gpsLongitude: gpsLongitude,
        distanceMeters: distanceMeters,
        isFlaggedLocation: isFlaggedLocation,
        syncStatus: 'pending',
        createdAt: DateTime.now().toUtc(),
      );

      return await repository.executeDailyClosure(closure);
    } catch (e) {
      return Error(ValidationFailure(message: e.toString()));
    }
  }
}
