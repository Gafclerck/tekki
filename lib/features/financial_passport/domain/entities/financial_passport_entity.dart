import 'package:equatable/equatable.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';

/// Entité immuable globale représentant le Passeport Financier in-app.
///
/// Calcule et expose le score de réputation sur 100, le détail des 4 piliers,
/// l'éligibilité (seuil minimal de 7 clôtures), la série en cours (streak)
/// et le message motivant.
class FinancialPassportEntity extends Equatable {
  FinancialPassportEntity({
    required this.overallScore,
    required this.breakdown,
    required this.isEligible,
    required this.totalClosures,
    required this.remainingClosures,
    required this.streak,
    String? encouragementMessage,
    DateTime? calculatedAt,
  }) : encouragementMessage =
           encouragementMessage ??
           _defaultEncouragementMessage(isEligible, remainingClosures),
       calculatedAt = (calculatedAt ?? DateTime.now()).toUtc() {
    if (overallScore < 0 || overallScore > 100) {
      throw ArgumentError('overallScore must be between 0 and 100');
    }
    if (totalClosures < 0) {
      throw ArgumentError('totalClosures cannot be negative');
    }
    if (remainingClosures < 0) {
      throw ArgumentError('remainingClosures cannot be negative');
    }
    if (streak < 0) {
      throw ArgumentError('streak cannot be negative');
    }
  }

  const FinancialPassportEntity.raw({
    required this.overallScore,
    required this.breakdown,
    required this.isEligible,
    required this.totalClosures,
    required this.remainingClosures,
    required this.streak,
    required this.encouragementMessage,
    required this.calculatedAt,
  });

  /// Score global de réputation sur 100 (0 à 100).
  final int overallScore;

  /// Détail de la notation des 4 piliers et de leurs contributions pondérées.
  final ScoreBreakdownEntity breakdown;

  /// Statut d'éligibilité (actif si totalClosures >= 7, encouragement sinon).
  final bool isEligible;

  /// Nombre total de clôtures enregistrées sur la fenêtre de 30 jours.
  final int totalClosures;

  /// Nombre de clôtures restantes pour atteindre le seuil de 7 clôtures (0 si éligible).
  final int remainingClosures;

  /// Série continue de clôtures journalières consécutives (streak).
  final int streak;

  /// Message d'encouragement ou statut bienveillant.
  final String encouragementMessage;

  /// Horodatage UTC du calcul du passeport.
  final DateTime calculatedAt;

  static String _defaultEncouragementMessage(
    bool isEligible,
    int remainingClosures,
  ) {
    if (isEligible) {
      return 'Félicitations ! Votre passeport financier est actif et officiel.';
    }
    final unit = remainingClosures > 1 ? 'clôtures' : 'clôture';
    return 'Encore $remainingClosures $unit pour débloquer votre premier passeport officiel.';
  }

  FinancialPassportEntity copyWith({
    int? overallScore,
    ScoreBreakdownEntity? breakdown,
    bool? isEligible,
    int? totalClosures,
    int? remainingClosures,
    int? streak,
    String? encouragementMessage,
    DateTime? calculatedAt,
  }) {
    final newIsEligible = isEligible ?? this.isEligible;
    final newRemainingClosures = remainingClosures ?? this.remainingClosures;
    final newEncouragementMessage =
        encouragementMessage ??
        ((isEligible != null || remainingClosures != null)
            ? _defaultEncouragementMessage(newIsEligible, newRemainingClosures)
            : this.encouragementMessage);

    return FinancialPassportEntity(
      overallScore: overallScore ?? this.overallScore,
      breakdown: breakdown ?? this.breakdown,
      isEligible: newIsEligible,
      totalClosures: totalClosures ?? this.totalClosures,
      remainingClosures: newRemainingClosures,
      streak: streak ?? this.streak,
      encouragementMessage: newEncouragementMessage,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
    overallScore,
    breakdown,
    isEligible,
    totalClosures,
    remainingClosures,
    streak,
    encouragementMessage,
    calculatedAt,
  ];
}
