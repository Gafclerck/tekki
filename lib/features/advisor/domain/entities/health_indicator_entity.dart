import 'package:equatable/equatable.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';

/// Entité immuable représentant un axe d'évaluation de santé financière
/// au sein du Conseiller Tekki.
class HealthIndicatorEntity extends Equatable {
  const HealthIndicatorEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.diagnostic,
    required this.recommendation,
    required this.score,
  });

  /// Identifiant unique de l'indicateur
  /// (ex: 'caisse_regularity', 'karne_bor_recovery', 'cash_discipline', 'location_stability')
  final String id;

  /// Titre clair et vulgarisé sans jargon comptable
  final String title;

  /// Statut tricolore (conforme, attention, urgent)
  final HealthStatus status;

  /// Constat bienveillant en langage simple
  final String diagnostic;

  /// Recommandation actionnable immédiate
  final String recommendation;

  /// Score numérique sur 100
  final int score;

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    diagnostic,
    recommendation,
    score,
  ];
}
