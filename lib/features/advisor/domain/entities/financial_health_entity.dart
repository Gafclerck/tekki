import 'package:equatable/equatable.dart';
import 'package:tekki/features/advisor/domain/entities/health_indicator_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';

/// Entité immuable globale de diagnostic de santé financière
/// produite par le Conseiller Tekki.
class FinancialHealthEntity extends Equatable {
  const FinancialHealthEntity({
    required this.overallStatus,
    required this.summary,
    required this.indicators,
    required this.evaluatedAt,
  });

  /// Statut synthétique global (conforme, attention, urgent)
  final HealthStatus overallStatus;

  /// Résumé bienveillant et vulgarisé de la situation globale
  final String summary;

  /// Liste des indicateurs d'audit (les 4 piliers de gestion)
  final List<HealthIndicatorEntity> indicators;

  /// Horodatage de l'évaluation
  final DateTime evaluatedAt;

  /// Indicateur spécifique de régularité de caisse
  HealthIndicatorEntity? get caisseRegularity =>
      _findIndicator('caisse_regularity');

  /// Indicateur spécifique de recouvrement Karné Bor
  HealthIndicatorEntity? get karneBorRecovery =>
      _findIndicator('karne_bor_recovery');

  /// Indicateur spécifique de trésorerie et encaisse
  HealthIndicatorEntity? get cashDiscipline =>
      _findIndicator('cash_discipline');

  /// Indicateur spécifique de stabilité géographique
  HealthIndicatorEntity? get locationStability =>
      _findIndicator('location_stability');

  HealthIndicatorEntity? _findIndicator(String id) {
    try {
      return indicators.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [overallStatus, summary, indicators, evaluatedAt];
}
