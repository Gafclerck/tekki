import 'dart:math';

import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

/// Cas d'utilisation pur Dart calculant le score et le Passeport Financier
/// fondé sur les 4 piliers pondérés :
/// - 35% Régularité des clôtures journalières
/// - 40% Vélocité de recouvrement Karné Bor
/// - 15% Stabilité géographique GPS
/// - 10% Discipline d'encaisse déclarée
///
/// Seuil d'éligibilité : 7 clôtures minimales sur la fenêtre glissante de 30 jours.
class CalculateFinancialPassportUseCase {
  const CalculateFinancialPassportUseCase({required this.repository});

  final PassportRepository repository;

  Future<Result<FinancialPassportEntity, Failure>> call({
    DateTime? asOf,
    int windowDays = 30,
  }) {
    return repository.getFinancialPassport(asOf: asOf, windowDays: windowDays);
  }

  /// Calcul algorithmique pur Dart déterministe à partir des données locales de clôtures et de dettes.
  static FinancialPassportEntity computeFromData({
    required List<DailyClosureEntity> closures,
    List<DebtEntity>? debts,
    Map<String, List<DebtPaymentEntity>>? paymentsByDebtId,
    RecoveryVelocityEntity? recoveryVelocity,
    int? streak,
    DateTime? asOf,
    int windowDays = 30,
    bool filterByWindow = true,
  }) {
    final referenceDate = (asOf ?? DateTime.now()).toUtc();
    final refDay = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final startDay = refDay.subtract(Duration(days: windowDays));

    // Filtrage des clôtures sur la fenêtre glissante
    final List<DailyClosureEntity> relevantClosures;
    if (filterByWindow) {
      relevantClosures = closures.where((c) {
        final d = _extractClosureDate(c);
        return !d.isBefore(startDay) && !d.isAfter(refDay);
      }).toList();
    } else {
      relevantClosures = closures;
    }

    final totalClosures = relevantClosures
        .map((c) => _formatDate(_extractClosureDate(c)))
        .toSet()
        .length;

    // 1. Pilier Régularité Clôtures (35%)
    // Cible de 20 clôtures sur 30 jours pour obtenir 100% du pilier
    final int closureScore = (totalClosures / 20.0 * 100).clamp(0, 100).round();
    final double weightedClosure = closureScore * 0.35;

    // 2. Pilier Vélocité Karné Bor (40%)
    final int debtRate;
    if (recoveryVelocity != null) {
      debtRate = recoveryVelocity.rate;
    } else if (debts != null) {
      final computed = CalculateRecoveryVelocityUseCase.computeFromDebts(
        debts: debts,
        paymentsByDebtId: paymentsByDebtId,
        asOf: referenceDate,
        windowDays: windowDays,
      );
      debtRate = computed.rate;
    } else {
      // 0 dette dans Karné Bor -> 100% de vélocité
      debtRate = 100;
    }
    final double weightedDebt = debtRate * 0.40;

    // 3. Pilier Stabilité GPS (15%)
    // validGpsClosures = nombre de clôtures où isFlaggedLocation == false
    final int gpsScore;
    if (totalClosures == 0) {
      gpsScore = 100;
    } else {
      final validGpsClosures = relevantClosures
          .where((c) => !c.isFlaggedLocation)
          .length;
      gpsScore = ((validGpsClosures / relevantClosures.length) * 100)
          .clamp(0, 100)
          .round();
    }
    final double weightedGps = gpsScore * 0.15;

    // 4. Pilier Discipline d'Encaisse (10%)
    // consistentCashClosures = cashCounted == 0 && theoreticalCash == 0 (cohérent),
    // ou cashCounted > 0 et écart <= max(500, theoreticalCash ~/ 10)
    final int cashScore;
    if (totalClosures == 0) {
      cashScore = 100;
    } else {
      final consistentCashClosures = relevantClosures.where((c) {
        if (c.cashCounted == 0 && c.theoreticalCash == 0) return true;
        if (c.cashCounted <= 0) return false;
        final diff = (c.cashCounted - c.theoreticalCash).abs();
        final tolerance = max(500, c.theoreticalCash ~/ 10);
        return diff <= tolerance;
      }).length;
      cashScore = ((consistentCashClosures / relevantClosures.length) * 100)
          .clamp(0, 100)
          .round();
    }
    final double weightedCash = cashScore * 0.10;

    // 5. Score Global et Arrondi
    final int overallScore =
        (weightedClosure + weightedDebt + weightedGps + weightedCash)
            .round()
            .clamp(0, 100);

    // 6. Éligibilité et clôtures restantes
    final bool isEligible = totalClosures >= 7;
    final int remainingClosures = isEligible
        ? 0
        : (7 - totalClosures).clamp(0, 7);

    // Streak : évalue l'historique complet pour ne pas tronquer les séries > 30 jours
    final int calculatedStreak =
        streak ?? _calculateStreak(closures, referenceDate);

    final breakdown = ScoreBreakdownEntity(
      closureScore: closureScore,
      debtScore: debtRate,
      gpsScore: gpsScore,
      cashScore: cashScore,
      closureContribution: weightedClosure,
      debtContribution: weightedDebt,
      gpsContribution: weightedGps,
      cashContribution: weightedCash,
    );

    return FinancialPassportEntity(
      overallScore: overallScore,
      breakdown: breakdown,
      isEligible: isEligible,
      totalClosures: totalClosures,
      remainingClosures: remainingClosures,
      streak: calculatedStreak,
      calculatedAt: referenceDate,
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _extractClosureDate(DailyClosureEntity c) {
    final parsed = DateTime.tryParse(c.closureDate);
    if (parsed != null) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    final parts = c.closureDate.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime.utc(y, m, d);
      }
    }
    return DateTime.utc(c.createdAt.year, c.createdAt.month, c.createdAt.day);
  }

  static int _calculateStreak(
    List<DailyClosureEntity> closures,
    DateTime referenceDate,
  ) {
    if (closures.isEmpty) return 0;
    final closedDates = closures
        .map((c) => _formatDate(_extractClosureDate(c)))
        .toSet();

    final todayStr = _formatDate(referenceDate);
    final yesterdayStr = _formatDate(
      referenceDate.subtract(const Duration(days: 1)),
    );

    DateTime currentCheckDate;
    if (closedDates.contains(todayStr)) {
      currentCheckDate = referenceDate;
    } else if (closedDates.contains(yesterdayStr)) {
      currentCheckDate = referenceDate.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    while (closedDates.contains(_formatDate(currentCheckDate))) {
      streak++;
      currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
