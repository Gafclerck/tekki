import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/usecases/evaluate_loan_eligibility_use_case.dart';

void main() {
  late EvaluateLoanEligibilityUseCase useCase;
  const partners = FinancialPartnerCatalog.defaultPartners;

  setUp(() {
    useCase = const EvaluateLoanEligibilityUseCase();
  });

  FinancialPassportEntity createPassport({
    required int score,
    required int consecutiveClosures,
    bool isEligible = true,
  }) {
    return FinancialPassportEntity(
      overallScore: score,
      isEligible: isEligible,
      totalClosures: consecutiveClosures,
      remainingClosures: isEligible ? 0 : (7 - consecutiveClosures).clamp(0, 7),
      streak: consecutiveClosures,
      breakdown: ScoreBreakdownEntity(
        closureScore: score,
        debtScore: score,
        gpsScore: 100,
        cashScore: 90,
      ),
      calculatedAt: DateTime.now(),
    );
  }

  group('EvaluateLoanEligibilityUseCase Unit Tests', () {
    test('returns not eligible when passport is null', () {
      final eligibility = useCase(passport: null, partners: partners);

      expect(eligibility.isEligible, isFalse);
      expect(eligibility.maxBorrowingCapacity, equals(0));
      expect(eligibility.grade, equals('C'));
      expect(eligibility.eligiblePartnerIds, isEmpty);
    });

    test('returns not eligible when closures count < 7', () {
      final passport = createPassport(
        score: 75,
        consecutiveClosures: 5,
        isEligible: false,
      );

      final eligibility = useCase(passport: passport, partners: partners);

      expect(eligibility.isEligible, isFalse);
      expect(eligibility.maxBorrowingCapacity, equals(0));
      expect(eligibility.closuresCount, equals(5));
      expect(eligibility.recommendationMessage, contains('2 clôtures'));
    });

    test(
      'returns eligible with Grade A and Baobab/PAMECAS when closures >= 7 and score = 65',
      () {
        final passport = createPassport(
          score: 65,
          consecutiveClosures: 8,
          isEligible: true,
        );

        final eligibility = useCase(passport: passport, partners: partners);

        expect(eligibility.isEligible, isTrue);
        expect(eligibility.maxBorrowingCapacity, greaterThan(200000));
        expect(eligibility.grade, equals('B'));
        expect(eligibility.eligiblePartnerIds, contains('baobab_sn'));
        expect(eligibility.eligiblePartnerIds, contains('pamecas_sn'));
        // Cofina needs 70 and 14 closures
        expect(eligibility.eligiblePartnerIds, isNot(contains('cofina_sn')));
      },
    );

    test(
      'returns Grade A+ with all partners when closures = 14 and score = 85',
      () {
        final passport = createPassport(
          score: 85,
          consecutiveClosures: 14,
          isEligible: true,
        );

        final eligibility = useCase(passport: passport, partners: partners);

        expect(eligibility.isEligible, isTrue);
        expect(eligibility.grade, equals('A+'));
        expect(eligibility.maxBorrowingCapacity, greaterThanOrEqualTo(1000000));
        expect(eligibility.eligiblePartnerIds.length, equals(4));
        expect(eligibility.eligiblePartnerIds, contains('baobab_sn'));
        expect(eligibility.eligiblePartnerIds, contains('cofina_sn'));
        expect(eligibility.eligiblePartnerIds, contains('pamecas_sn'));
        expect(eligibility.eligiblePartnerIds, contains('ecobank_sn'));
      },
    );
  });
}
