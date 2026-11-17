import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

abstract class SalesRepository {
  Future<Result<SaleEntity, Failure>> recordSale(SaleEntity sale);
  Future<Result<SaleEntity?, Failure>> getSaleById(String id);
  Future<Result<List<SaleEntity>, Failure>> getAllSales({
    int limit = 50,
    int? offset,
  });
  Future<Result<List<SaleEntity>, Failure>> getOrphanSales();
  Stream<List<SaleEntity>> watchOrphanSales();
  Stream<List<SaleEntity>> watchAllSales({int limit = 50, int? offset});
}
