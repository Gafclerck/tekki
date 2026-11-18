import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';

class EvaluateLoanEligibilityUseCase {
  const EvaluateLoanEligibilityUseCase();

  LoanEligibilityEntity call({
    required FinancialPassportEntity? passport,
    required List<FinancialPartnerEntity> partners,
  }) {
    if (passport == null) {
      return const LoanEligibilityEntity(
        isEligible: false,
        maxBorrowingCapacity: 0,
        currentScore: 0,
        closuresCount: 0,
        grade: 'C',
        statusSummary: 'Passeport non activé',
        eligiblePartnerIds: [],
        recommendationMessage:
            'Enregistrez vos premières ventes et clôtures pour activer votre Passeport Financier.',
      );
    }

    final closuresCount = passport.totalClosures;
    final score = passport.overallScore;

    if (!passport.isEligible || closuresCount < 7) {
      final needed = passport.remainingClosures > 0
          ? passport.remainingClosures
          : (7 - closuresCount);
      return LoanEligibilityEntity(
        isEligible: false,
        maxBorrowingCapacity: 0,
        currentScore: score,
        closuresCount: closuresCount,
        grade: 'C',
        statusSummary: 'Passeport en cours de consolidation',
        eligiblePartnerIds: const [],
        recommendationMessage:
            'Encore $needed clôture${needed > 1 ? 's' : ''} quotidienne${needed > 1 ? 's' : ''} pour débloquer votre accès au crédit bancaire.',
      );
    }

    // Calcul de la capacité d'emprunt certifiée en FCFA
    // Règle prudentielle BCEAO : mensualité max ~ 33% du flux moyen estimé
    // Score élevé et régularité augmentent la capacité d'emprunt
    const baseCapacity = 500000;
    final scoreMultiplier = (score.clamp(50, 100)) / 100.0;
    final streakMultiplier = 1.0 + (passport.streak.clamp(0, 30) * 0.02);

    int rawCapacity =
        (baseCapacity *
                scoreMultiplier *
                streakMultiplier *
                (closuresCount / 7.0))
            .round();

    // Arrondi au multiple de 50 000 FCFA supérieur / plus proche
    rawCapacity = ((rawCapacity / 50000).round() * 50000).clamp(
      200000,
      5000000,
    );

    // Détermination du Grade
    final String grade;
    final String recommendation;
    if (score >= 80) {
      grade = 'A+';
      recommendation =
          'Profil d\'excellence. Éligible aux taux les plus bas et déblocage express chez tous les partenaires.';
    } else if (score >= 70) {
      grade = 'A';
      recommendation =
          'Très bon profil de solvabilité. Éligible à un crédit de réassort immédiat.';
    } else if (score >= 55) {
      grade = 'B';
      recommendation =
          'Profil satisfaisant. Éligible aux micro-crédits de trésorerie.';
    } else {
      grade = 'C';
      recommendation =
          'Continuez vos clôtures régulières pour améliorer votre score et augmenter votre plafond.';
    }

    // Filtrage des partenaires dont les critères sont validés
    final eligiblePartnerIds = partners
        .where(
          (p) =>
              p.requiredMinScore <= score &&
              p.requiredClosuresCount <= closuresCount,
        )
        .map((p) => p.id)
        .toList();

    return LoanEligibilityEntity(
      isEligible: eligiblePartnerIds.isNotEmpty,
      maxBorrowingCapacity: rawCapacity,
      currentScore: score,
      closuresCount: closuresCount,
      grade: grade,
      statusSummary: 'Éligible au crédit certifié',
      eligiblePartnerIds: eligiblePartnerIds,
      recommendationMessage: recommendation,
    );
  }
}
