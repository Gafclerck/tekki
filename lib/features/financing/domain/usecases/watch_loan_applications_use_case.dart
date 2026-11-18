import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';

class WatchLoanApplicationsUseCase {
  const WatchLoanApplicationsUseCase({required this.repository});

  final LoanApplicationRepository repository;

  Stream<List<LoanApplicationEntity>> call({required String shopId}) {
    return repository.watchApplications(shopId: shopId);
  }
}
