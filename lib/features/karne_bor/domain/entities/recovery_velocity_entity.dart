import 'package:equatable/equatable.dart';

enum RecoveryHealthLevel {
  excellent,
  moderate,
  critical,
}

/// Entité métier représentant la vélocité de recouvrement des créances.
///
/// Modèle 100 % Offline-First, pur Dart, sans dépendance Drift ni Flutter.
class RecoveryVelocityEntity extends Equatable {
  const RecoveryVelocityEntity({
    required this.rate,
    required this.totalDueAmount,
    required this.totalRecoveredAmount,
    required this.healthStatus,
    this.healthLevel = RecoveryHealthLevel.excellent,
    this.windowDays = 30,
  });

  /// Taux de vélocité de recouvrement borné strictement entre 0 et 100
  final int rate;

  /// Montant total des créances exigibles sur la fenêtre glissante
  final int totalDueAmount;

  /// Montant total recouvré dans les délais sur la fenêtre glissante
  final int totalRecoveredAmount;

  /// Message diagnostic bienveillant et motivant
  final String healthStatus;

  /// Niveau qualitatif de santé financière (pour orientation visuelle)
  final RecoveryHealthLevel healthLevel;

  /// Durée de la fenêtre glissante en jours (défaut 30 jours)
  final int windowDays;

  @override
  List<Object?> get props => [
        rate,
        totalDueAmount,
        totalRecoveredAmount,
        healthStatus,
        healthLevel,
        windowDays,
      ];

  @override
  String toString() {
    return 'RecoveryVelocityEntity(rate: $rate%, recovered: $totalRecoveredAmount/$totalDueAmount, health: $healthStatus)';
  }
}
