import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';

/// Contrat abstrait du repository pour l'évaluation de la santé financière
/// et le Conseiller Tekki.
abstract class AdvisorRepository {
  /// Évalue la santé financière de la boutique sur la période spécifiée.
  Future<Result<FinancialHealthEntity, Failure>> evaluateFinancialHealth({
    DateTime? asOf,
    int windowDays = 30,
  });
}
