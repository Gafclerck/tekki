import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';

class ClosureRepositoryImpl implements ClosureRepository {
  const ClosureRepositoryImpl({required this.localDataSource});

  final ClosureLocalDataSource localDataSource;

  @override
  Future<Result<int, Failure>> getPrefillSalesAmount(
    DateTime cutoffTimestamp,
  ) async {
    try {
      final amount =
          await localDataSource.getPrefillSalesAmount(cutoffTimestamp);
      return Success(amount);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(
        DatabaseFailure(message: 'Erreur inattendue de base de données : $e'),
      );
    }
  }

  @override
  Future<Result<DailyClosureEntity, Failure>> executeDailyClosure(
    DailyClosureEntity closure,
  ) async {
    try {
      final created = await localDataSource.executeDailyClosure(closure);
      return Success(created);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(
        DatabaseFailure(message: 'Erreur inattendue de base de données : $e'),
      );
    }
  }

  @override
  Future<Result<DailyClosureEntity?, Failure>> getClosureById(String id) async {
    try {
      final closure = await localDataSource.getClosureById(id);
      return Success(closure);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(
        DatabaseFailure(message: 'Erreur inattendue : $e'),
      );
    }
  }

  @override
  Future<Result<List<DailyClosureEntity>, Failure>> getAllClosures({
    int limit = 50,
    int? offset,
  }) async {
    try {
      final closures = await localDataSource.getAllClosures(
        limit: limit,
        offset: offset,
      );
      return Success(closures);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(
        DatabaseFailure(message: 'Erreur inattendue : $e'),
      );
    }
  }
}
