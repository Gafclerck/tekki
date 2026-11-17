import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:uuid/uuid.dart';

class RecordQuickSaleUseCase {
  const RecordQuickSaleUseCase({
    required this.repository,
    this.uuid = const Uuid(),
  });

  final SalesRepository repository;
  final Uuid uuid;

  Future<Result<SaleEntity, Failure>> call({
    required int amount,
    PaymentMethod paymentMethod = PaymentMethod.especes,
    DateTime? recordedAt,
  }) async {
    if (amount <= 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant de la vente doit être strictement supérieur à zéro.',
        ),
      );
    }
    if (amount > 999999999) {
      return const Error(
        ValidationFailure(
          message: 'Le montant de la vente dépasse le plafond autorisé (999 999 999 FCFA).',
        ),
      );
    }

    try {
      final sale = SaleEntity(
        id: uuid.v4(),
        amount: amount,
        paymentMethod: paymentMethod,
        recordedAt: (recordedAt ?? DateTime.now()).toUtc(),
        closureId: null,
        syncStatus: 'pending',
      );

      return await repository.recordSale(sale);
    } catch (e) {
      return Error(ValidationFailure(message: e.toString()));
    }
  }
}
