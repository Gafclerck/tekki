import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';

/// Contrat d'accès et de calcul du Passeport Financier.
///
/// Respecte le principe d'inversion de dépendance (DIP) et s'exécute
/// en pur Dart sans couplage à l'infrastructure ni au réseau.
abstract class PassportRepository {
  /// Récupère et calcule le Passeport Financier sur une fenêtre glissante (30 jours).
  Future<Result<FinancialPassportEntity, Failure>> getFinancialPassport({
    DateTime? asOf,
    int windowDays = 30,
  });
}
