import 'package:equatable/equatable.dart';

/// Entité immuable représentant le détail des scores des 4 piliers
/// et leurs contributions pondérées pour le Passeport Financier Tekki.
///
/// Piliers et pondérations :
/// 1. Régularité des clôtures journalières (35 %)
/// 2. Vélocité de recouvrement Karné Bor (40 %)
/// 3. Stabilité géographique GPS anti-fraude (15 %)
/// 4. Discipline d'encaisse déclarée (10 %)
class ScoreBreakdownEntity extends Equatable {
  ScoreBreakdownEntity({
    required this.closureScore,
    required this.debtScore,
    required this.gpsScore,
    required this.cashScore,
    double? closureContribution,
    double? debtContribution,
    double? gpsContribution,
    double? cashContribution,
  }) : closureContribution = closureContribution ?? (closureScore * 0.35),
       debtContribution = debtContribution ?? (debtScore * 0.40),
       gpsContribution = gpsContribution ?? (gpsScore * 0.15),
       cashContribution = cashContribution ?? (cashScore * 0.10) {
    if (closureScore < 0 || closureScore > 100) {
      throw ArgumentError('closureScore must be between 0 and 100');
    }
    if (debtScore < 0 || debtScore > 100) {
      throw ArgumentError('debtScore must be between 0 and 100');
    }
    if (gpsScore < 0 || gpsScore > 100) {
      throw ArgumentError('gpsScore must be between 0 and 100');
    }
    if (cashScore < 0 || cashScore > 100) {
      throw ArgumentError('cashScore must be between 0 and 100');
    }
  }

  const ScoreBreakdownEntity.raw({
    required this.closureScore,
    required this.debtScore,
    required this.gpsScore,
    required this.cashScore,
    required this.closureContribution,
    required this.debtContribution,
    required this.gpsContribution,
    required this.cashContribution,
  });

  /// Score brut du pilier Régularité des clôtures (0 à 100). Poids : 35 %
  final int closureScore;

  /// Score brut du pilier Vélocité Karné Bor (0 à 100). Poids : 40 %
  final int debtScore;

  /// Score brut du pilier Stabilité GPS (0 à 100). Poids : 15 %
  final int gpsScore;

  /// Score brut du pilier Discipline d'encaisse (0 à 100). Poids : 10 %
  final int cashScore;

  /// Contribution pondérée du pilier clôtures (closureScore * 0.35).
  final double closureContribution;

  /// Contribution pondérée du pilier vélocité de dette (debtScore * 0.40).
  final double debtContribution;

  /// Contribution pondérée du pilier stabilité GPS (gpsScore * 0.15).
  final double gpsContribution;

  /// Contribution pondérée du pilier discipline d'encaisse (cashScore * 0.10).
  final double cashContribution;

  /// Somme brute des 4 contributions pondérées avant arrondi global.
  double get totalContribution =>
      closureContribution +
      debtContribution +
      gpsContribution +
      cashContribution;

  ScoreBreakdownEntity copyWith({
    int? closureScore,
    int? debtScore,
    int? gpsScore,
    int? cashScore,
    double? closureContribution,
    double? debtContribution,
    double? gpsContribution,
    double? cashContribution,
  }) {
    final newClosureScore = closureScore ?? this.closureScore;
    final newDebtScore = debtScore ?? this.debtScore;
    final newGpsScore = gpsScore ?? this.gpsScore;
    final newCashScore = cashScore ?? this.cashScore;

    return ScoreBreakdownEntity(
      closureScore: newClosureScore,
      debtScore: newDebtScore,
      gpsScore: newGpsScore,
      cashScore: newCashScore,
      closureContribution:
          closureContribution ??
          (closureScore != null
              ? newClosureScore * 0.35
              : this.closureContribution),
      debtContribution:
          debtContribution ??
          (debtScore != null ? newDebtScore * 0.40 : this.debtContribution),
      gpsContribution:
          gpsContribution ??
          (gpsScore != null ? newGpsScore * 0.15 : this.gpsContribution),
      cashContribution:
          cashContribution ??
          (cashScore != null ? newCashScore * 0.10 : this.cashContribution),
    );
  }

  @override
  List<Object?> get props => [
    closureScore,
    debtScore,
    gpsScore,
    cashScore,
    closureContribution,
    debtContribution,
    gpsContribution,
    cashContribution,
  ];
}
