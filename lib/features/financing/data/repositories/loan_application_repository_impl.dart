import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/data/datasources/loan_application_local_data_source.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';

class LoanApplicationRepositoryImpl implements LoanApplicationRepository {
  const LoanApplicationRepositoryImpl({required this.dataSource});

  final LoanApplicationLocalDataSource dataSource;

  @override
  Future<Result<LoanApplicationEntity, Failure>> submitApplication(
    LoanApplicationEntity application,
  ) async {
    try {
      await dataSource.insertApplication(application);
      return Result.success(application);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Erreur inattendue lors du dépôt de la demande : $e',
        ),
      );
    }
  }

  @override
  Stream<List<LoanApplicationEntity>> watchApplications({
    required String shopId,
  }) {
    return dataSource.watchApplications(shopId: shopId);
  }

  @override
  Future<List<LoanApplicationEntity>> getApplications({
    required String shopId,
  }) async {
    return dataSource.getApplications(shopId: shopId);
  }
}
