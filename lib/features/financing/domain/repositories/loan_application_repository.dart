import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';

abstract class LoanApplicationRepository {
  Future<Result<LoanApplicationEntity, Failure>> submitApplication(
    LoanApplicationEntity application,
  );
  Stream<List<LoanApplicationEntity>> watchApplications({
    required String shopId,
  });
  Future<List<LoanApplicationEntity>> getApplications({required String shopId});
}
