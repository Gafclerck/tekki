import 'dart:math';

import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_indicator_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';
import 'package:tekki/features/advisor/domain/repositories/advisor_repository.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

/// Cas d'utilisation pur Dart évaluant de manière 100% déterministe
/// la santé financière de la boutique (Conseiller Tekki).
///
/// Analyse 4 métriques de gestion traduites en feux tricolores (Vert/Orange/Rouge) :
/// 1. Régularité de caisse (clôtures journalières)
/// 2. Recouvrement Karné Bor (crédit client & vélocité)
/// 3. Discipline de trésorerie (cohérence encaisse théorique vs comptée)
/// 4. Stabilité d'ancrage (ancrage géographique au point de vente)
class EvaluateFinancialHealthUseCase {
  const EvaluateFinancialHealthUseCase({required this.repository});

  final AdvisorRepository repository;

  Future<Result<FinancialHealthEntity, Failure>> call({
    DateTime? asOf,
    int windowDays = 30,
  }) {
    return repository.evaluateFinancialHealth(
      asOf: asOf,
      windowDays: windowDays,
    );
  }

  /// Calcul algorithmique pur Dart déterministe et autonome (zéro réseau, zéro LLM).
  static FinancialHealthEntity computeFromData({
    required List<DailyClosureEntity> closures,
    List<DebtEntity>? debts,
    Map<String, List<DebtPaymentEntity>>? paymentsByDebtId,
    RecoveryVelocityEntity? recoveryVelocity,
    DateTime? asOf,
    int windowDays = 30,
    bool isNewShop = false,
  }) {
    final referenceDate = (asOf ?? DateTime.now()).toUtc();
    final refDay = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final startDay = refDay.subtract(Duration(days: windowDays));

    // Filtrage des clôtures sur la fenêtre glissante
    final relevantClosures = closures.where((c) {
      final d = _extractClosureDate(c);
      return !d.isBefore(startDay) && !d.isAfter(refDay);
    }).toList();

    // 1. Indicateur : Régularité de caisse
    final caisseIndicator = _evaluateCaisseRegularity(
      allClosures: closures,
      relevantClosures: relevantClosures,
      refDay: refDay,
      isNewShop: isNewShop,
    );

    // 2. Indicateur : Recouvrement Karné Bor
    final debtsIndicator = _evaluateKarneBorRecovery(
      debts: debts,
      paymentsByDebtId: paymentsByDebtId,
      recoveryVelocity: recoveryVelocity,
      referenceDate: referenceDate,
      windowDays: windowDays,
    );

    // 3. Indicateur : Discipline de trésorerie
    final cashIndicator = _evaluateCashDiscipline(
      relevantClosures: relevantClosures,
    );

    // 4. Indicateur : Stabilité d'ancrage
    final locationIndicator = _evaluateLocationStability(
      relevantClosures: relevantClosures,
    );

    final indicators = [
      caisseIndicator,
      debtsIndicator,
      cashIndicator,
      locationIndicator,
    ];

    // Synthèse et statut global
    final HealthStatus overallStatus;
    final String summary;

    final hasUrgent = indicators.any((i) => i.status == HealthStatus.urgent);
    final hasAttention = indicators.any(
      (i) => i.status == HealthStatus.attention,
    );

    if (hasUrgent) {
      overallStatus = HealthStatus.urgent;
      summary =
          'Attention requise : certains points de gestion nécessitent votre intervention immédiate.';
    } else if (hasAttention) {
      overallStatus = HealthStatus.attention;
      summary =
          'Activité stable avec des points de vigilance à surveiller pour progresser.';
    } else {
      overallStatus = HealthStatus.conforme;
      summary =
          'Bravo ! La santé financière de votre boutique est saine et bien maîtrisée.';
    }

    return FinancialHealthEntity(
      overallStatus: overallStatus,
      summary: summary,
      indicators: indicators,
      evaluatedAt: referenceDate,
    );
  }

  static HealthIndicatorEntity _evaluateCaisseRegularity({
    required List<DailyClosureEntity> allClosures,
    required List<DailyClosureEntity> relevantClosures,
    required DateTime refDay,
    required bool isNewShop,
  }) {
    if (allClosures.isEmpty) {
      if (isNewShop) {
        return const HealthIndicatorEntity(
          id: 'caisse_regularity',
          title: 'Régularité de caisse',
          status: HealthStatus.conforme,
          diagnostic:
              'Bienvenue sur Tekki ! Votre caisse est prête pour vos premières ventes.',
          recommendation:
              'Effectuez votre première clôture express ce soir au moment de fermer boutique.',
          score: 100,
        );
      } else {
        return const HealthIndicatorEntity(
          id: 'caisse_regularity',
          title: 'Régularité de caisse',
          status: HealthStatus.urgent,
          diagnostic: 'Aucune clôture de caisse enregistrée récemment.',
          recommendation:
              'Effectuez une clôture express ce soir pour sécuriser vos chiffres.',
          score: 0,
        );
      }
    }

    // Calcul des jours uniques clôturés
    final uniqueClosureDays = relevantClosures
        .map((c) => _formatDate(_extractClosureDate(c)))
        .toSet()
        .length;

    // Dernière clôture globale
    final sortedClosures = List<DailyClosureEntity>.from(allClosures)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final lastClosureDate = _extractClosureDate(sortedClosures.first);
    final daysSinceLastClosure = refDay.difference(lastClosureDate).inDays;

    final int score = (uniqueClosureDays / 20.0 * 100).clamp(0, 100).round();

    if (daysSinceLastClosure > 3) {
      return HealthIndicatorEntity(
        id: 'caisse_regularity',
        title: 'Régularité de caisse',
        status: HealthStatus.urgent,
        diagnostic:
            'Aucune clôture de caisse depuis plus de 3 jours ($daysSinceLastClosure jours sans clôture).',
        recommendation:
            'Faites le point ce soir avec la clôture express pour reprendre le fil.',
        score: max(20, score),
      );
    } else if (uniqueClosureDays < 7) {
      return HealthIndicatorEntity(
        id: 'caisse_regularity',
        title: 'Régularité de caisse',
        status: HealthStatus.attention,
        diagnostic:
            'Vous avez clôturé $uniqueClosureDays fois ce mois-ci. L\'idéal est de clôturer chaque soir.',
        recommendation:
            'La régularité quotidienne renforce la confiance de vos partenaires.',
        score: score,
      );
    } else {
      return HealthIndicatorEntity(
        id: 'caisse_regularity',
        title: 'Régularité de caisse',
        status: HealthStatus.conforme,
        diagnostic:
            'Excellente discipline ! Vous tenez votre caisse avec une grande régularité.',
        recommendation:
            'Continuez ainsi, chaque clôture solidifie votre historique.',
        score: score,
      );
    }
  }

  static HealthIndicatorEntity _evaluateKarneBorRecovery({
    required List<DebtEntity>? debts,
    required Map<String, List<DebtPaymentEntity>>? paymentsByDebtId,
    required RecoveryVelocityEntity? recoveryVelocity,
    required DateTime referenceDate,
    required int windowDays,
  }) {
    if (debts == null || debts.isEmpty) {
      return const HealthIndicatorEntity(
        id: 'karne_bor_recovery',
        title: 'Recouvrement Karné Bor',
        status: HealthStatus.conforme,
        diagnostic:
            'Aucun crédit client en attente. Votre argent est en sécurité.',
        recommendation:
            'Notez immédiatement dans le Karné Bor toute vente accordée à crédit.',
        score: 100,
      );
    }

    final int rate;
    if (recoveryVelocity != null) {
      rate = recoveryVelocity.rate;
    } else {
      final computed = CalculateRecoveryVelocityUseCase.computeFromDebts(
        debts: debts,
        paymentsByDebtId: paymentsByDebtId,
        asOf: referenceDate,
        windowDays: windowDays,
      );
      rate = computed.rate;
    }

    // Analyse des retards sur dettes non entièrement payées
    bool hasCriticalOverdue = false;
    bool hasModerateOverdue = false;

    for (final debt in debts) {
      if (debt.status == DebtStatus.settled || debt.remainingAmount == 0) {
        continue;
      }
      final refTarget = debt.dueDate;
      final overdueDays = referenceDate.difference(refTarget).inDays;
      if (overdueDays > 30) {
        hasCriticalOverdue = true;
      } else if (overdueDays > 7) {
        hasModerateOverdue = true;
      }
    }

    if (hasCriticalOverdue || rate < 50) {
      return HealthIndicatorEntity(
        id: 'karne_bor_recovery',
        title: 'Recouvrement Karné Bor',
        status: HealthStatus.urgent,
        diagnostic:
            'Des dettes dépassent 30 jours de retard. L\'argent dehors tarde à rentrer.',
        recommendation:
            'Relancez en 1-clic vos clients débiteurs sur WhatsApp.',
        score: rate,
      );
    } else if (hasModerateOverdue || rate < 80) {
      return HealthIndicatorEntity(
        id: 'karne_bor_recovery',
        title: 'Recouvrement Karné Bor',
        status: HealthStatus.attention,
        diagnostic:
            'Certains règlements tardent. Taux de recouvrement actuel de $rate%.',
        recommendation:
            'Pensez à rappeler vos débiteurs avant que la dette ne devienne difficile.',
        score: rate,
      );
    } else {
      return HealthIndicatorEntity(
        id: 'karne_bor_recovery',
        title: 'Recouvrement Karné Bor',
        status: HealthStatus.conforme,
        diagnostic:
            'Vos clients vous remboursent vite et bien ($rate% de vélocité).',
        recommendation: 'Maintenez de bons délais avec vos clients réguliers.',
        score: rate,
      );
    }
  }

  static HealthIndicatorEntity _evaluateCashDiscipline({
    required List<DailyClosureEntity> relevantClosures,
  }) {
    if (relevantClosures.isEmpty) {
      return const HealthIndicatorEntity(
        id: 'cash_discipline',
        title: 'Discipline de trésorerie',
        status: HealthStatus.conforme,
        diagnostic:
            'Trésorerie prête. Vos espèces seront suivies à chaque clôture.',
        recommendation:
            'Séparez bien l\'argent de la boutique de vos dépenses personnelles.',
        score: 100,
      );
    }

    int discrepancyCount = 0;
    for (final c in relevantClosures) {
      final diff = (c.cashCounted - c.theoreticalCash).abs();
      final tolerance = max(500, c.theoreticalCash ~/ 10);
      if (diff > tolerance) {
        discrepancyCount++;
      }
    }

    final double discrepancyRatio = discrepancyCount / relevantClosures.length;
    final int score =
        (((relevantClosures.length - discrepancyCount) /
                    relevantClosures.length) *
                100)
            .round()
            .clamp(0, 100);

    if (discrepancyRatio > 0.35) {
      return HealthIndicatorEntity(
        id: 'cash_discipline',
        title: 'Discipline de trésorerie',
        status: HealthStatus.urgent,
        diagnostic:
            'Des écarts de caisse fréquents ont été constatés ($discrepancyCount clôtures avec écart).',
        recommendation:
            'Vérifiez attentivement les billets et pièces lors du comptage du soir.',
        score: score,
      );
    } else if (discrepancyRatio > 0.15) {
      return HealthIndicatorEntity(
        id: 'cash_discipline',
        title: 'Discipline de trésorerie',
        status: HealthStatus.attention,
        diagnostic:
            'Quelques écarts entre l\'encaisse comptée et l\'encaisse théorique.',
        recommendation:
            'Pensez à noter chaque petite dépense ou sortie d\'espèces en journée.',
        score: score,
      );
    } else {
      return HealthIndicatorEntity(
        id: 'cash_discipline',
        title: 'Discipline de trésorerie',
        status: HealthStatus.conforme,
        diagnostic:
            'Votre boîte à monnaie correspond fidèlement à vos ventes enregistrées.',
        recommendation:
            'Gardez toujours un fond de caisse propre pour faciliter la monnaie.',
        score: score,
      );
    }
  }

  static HealthIndicatorEntity _evaluateLocationStability({
    required List<DailyClosureEntity> relevantClosures,
  }) {
    if (relevantClosures.isEmpty) {
      return const HealthIndicatorEntity(
        id: 'location_stability',
        title: 'Stabilité d\'ancrage',
        status: HealthStatus.conforme,
        diagnostic:
            'Ancrage boutique prêt pour votre première clôture sur place.',
        recommendation:
            'Effectuez vos clôtures journalières directement au magasin.',
        score: 100,
      );
    }

    final flaggedCount = relevantClosures
        .where((c) => c.isFlaggedLocation)
        .length;
    final flaggedRatio = flaggedCount / relevantClosures.length;
    final int score =
        (((relevantClosures.length - flaggedCount) / relevantClosures.length) *
                100)
            .round()
            .clamp(0, 100);

    if (flaggedRatio >= 0.50) {
      return HealthIndicatorEntity(
        id: 'location_stability',
        title: 'Stabilité d\'ancrage',
        status: HealthStatus.urgent,
        diagnostic:
            'La majorité de vos clôtures ($flaggedCount) sont faites hors du périmètre boutique.',
        recommendation:
            'Validez la clôture avant de quitter le comptoir pour certifier votre activité.',
        score: score,
      );
    } else if (flaggedRatio >= 0.25) {
      return HealthIndicatorEntity(
        id: 'location_stability',
        title: 'Stabilité d\'ancrage',
        status: HealthStatus.attention,
        diagnostic:
            'Plusieurs clôtures récentes ont été effectuées loin de votre boutique.',
        recommendation:
            'Pensez à clôturer sur place pour renforcer l\'authenticité de votre historique.',
        score: score,
      );
    } else {
      return HealthIndicatorEntity(
        id: 'location_stability',
        title: 'Stabilité d\'ancrage',
        status: HealthStatus.conforme,
        diagnostic:
            'Vos opérations sont parfaitement ancrées à votre point de vente.',
        recommendation:
            'Votre assiduité au comptoir donne un signal très positif aux prêteurs.',
        score: score,
      );
    }
  }

  static DateTime _extractClosureDate(DailyClosureEntity closure) {
    final parts = closure.closureDate.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime.utc(y, m, d);
      }
    }
    final c = closure.createdAt.toUtc();
    return DateTime.utc(c.year, c.month, c.day);
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
