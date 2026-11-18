import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';

class SubmitLoanApplicationUseCase {
  const SubmitLoanApplicationUseCase({required this.repository});

  final LoanApplicationRepository repository;

  Future<Result<LoanApplicationEntity, Failure>> call(
    LoanApplicationEntity application,
  ) async {
    if (application.requestedAmount <= 0) {
      return Result.failure(
        const ValidationFailure(
          message:
              'Le montant demandé doit être strictement supérieur à 0 FCFA.',
        ),
      );
    }
    if (application.durationMonths <= 0) {
      return Result.failure(
        const ValidationFailure(
          message: 'La durée doit être d\'au moins 1 mois.',
        ),
      );
    }
    if (application.partnerId.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(
          message: 'Un partenaire financier doit être sélectionné.',
        ),
      );
    }

    return repository.submitApplication(application);
  }
}
