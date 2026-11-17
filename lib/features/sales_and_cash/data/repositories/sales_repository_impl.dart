import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl({required this.localDataSource});

  final SalesLocalDataSource localDataSource;

  @override
  Future<Result<SaleEntity, Failure>> recordSale(SaleEntity sale) async {
    try {
      await localDataSource.insertSale(sale);
      return Success(sale);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(
        DatabaseFailure(message: 'Erreur inattendue de base de données : $e'),
      );
    }
  }

  @override
  Future<Result<SaleEntity?, Failure>> getSaleById(String id) async {
    try {
      final sale = await localDataSource.getSaleById(id);
      return Success(sale);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Erreur inattendue : $e'));
    }
  }

  @override
  Future<Result<List<SaleEntity>, Failure>> getAllSales({
    int limit = 50,
    int? offset,
  }) async {
    try {
      final sales = await localDataSource.getAllSales(
        limit: limit,
        offset: offset,
      );
      return Success(sales);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Erreur inattendue : $e'));
    }
  }

  @override
  Future<Result<List<SaleEntity>, Failure>> getOrphanSales() async {
    try {
      final sales = await localDataSource.getOrphanSales();
      return Success(sales);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Erreur inattendue : $e'));
    }
  }

  @override
  Stream<List<SaleEntity>> watchOrphanSales() {
    return localDataSource.watchOrphanSales();
  }

  @override
  Stream<List<SaleEntity>> watchAllSales({int limit = 50, int? offset}) {
    return localDataSource.watchAllSales(limit: limit, offset: offset);
  }
}
