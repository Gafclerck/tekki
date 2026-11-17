import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockPassportRepository mockRepository;
  late CalculateFinancialPassportUseCase useCase;

  final now = DateTime.utc(2026, 11, 17, 12, 0);

  String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  setUp(() {
    mockRepository = MockPassportRepository();
    useCase = CalculateFinancialPassportUseCase(repository: mockRepository);
  });

  group('CalculateFinancialPassportUseCase', () {
    group('call', () {
      test(
        'delegates to repository getFinancialPassport with asOf and windowDays',
        () async {
          final expectedPassport = createTestFinancialPassport(
            overallScore: 85,
            totalClosures: 20,
            isEligible: true,
            streak: 5,
          );

          when(
            () => mockRepository.getFinancialPassport(
              asOf: any(named: 'asOf'),
              windowDays: any(named: 'windowDays'),
            ),
          ).thenAnswer((_) async => Success(expectedPassport));

          final result = await useCase(asOf: now, windowDays: 30);

          expect(result.isSuccess, isTrue);
          expect(result, Success(expectedPassport));
          verify(
            () =>
                mockRepository.getFinancialPassport(asOf: now, windowDays: 30),
          ).called(1);
        },
      );
    });

    group('computeFromData - I/O Matrix Scenarios', () {
      test(
        'Scenario 1: Moins de 7 clôtures (4 clôtures) -> isEligible = false, remaining = 3, message encouragement',
        () {
          final closures = List.generate(
            4,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 10000,
              totalExpensesAmount: 2000,
              cashCounted: 8000,
              isFlaggedLocation: false,
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );

          expect(result.isEligible, isFalse);
          expect(result.remainingClosures, 3);
          expect(result.totalClosures, 4);
          expect(
            result.encouragementMessage,
            'Encore 3 clôtures pour débloquer votre premier passeport officiel.',
          );
          // closureScore = (4 / 20 * 100) = 20 -> weighted = 7.0 pts
          // debtRate = 100 -> weighted = 40.0 pts
          // gpsScore = 100 -> weighted = 15.0 pts
          // cashScore = 100 -> weighted = 10.0 pts
          // overall = (7.0 + 40.0 + 15.0 + 10.0).round() = 72
          expect(result.breakdown.closureScore, 20);
          expect(result.breakdown.closureContribution, 7.0);
          expect(result.breakdown.debtScore, 100);
          expect(result.breakdown.debtContribution, 40.0);
          expect(result.breakdown.gpsScore, 100);
          expect(result.breakdown.gpsContribution, 15.0);
          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
          expect(result.overallScore, 72);
        },
      );

      test(
        'Scenario 2: Exactement 7 clôtures régulières, GPS valide, 0 dette en retard -> isEligible = true, remaining = 0',
        () {
          final closures = List.generate(
            7,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 15000,
              totalExpensesAmount: 3000,
              cashCounted: 12000,
              isFlaggedLocation: false,
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );

          expect(result.isEligible, isTrue);
          expect(result.remainingClosures, 0);
          expect(result.totalClosures, 7);
          expect(
            result.encouragementMessage,
            'Félicitations ! Votre passeport financier est actif et officiel.',
          );
          // closureScore = (7 / 20 * 100).round() = 35 -> contribution = 12.25 pts
          // debtRate = 100 -> contribution = 40.0 pts
          // gpsScore = 100 -> contribution = 15.0 pts
          // cashScore = 100 -> contribution = 10.0 pts
          // overallScore = (12.25 + 40 + 15 + 10).round() = 77
          expect(result.breakdown.closureScore, 35);
          expect(result.breakdown.closureContribution, 12.25);
          expect(result.breakdown.debtScore, 100);
          expect(result.breakdown.debtContribution, 40.0);
          expect(result.breakdown.gpsScore, 100);
          expect(result.breakdown.gpsContribution, 15.0);
          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
          expect(result.overallScore, 77);

          // Avec 9 clôtures régulières, score >= 80 (9 / 20 * 100 = 45 -> 15.75 + 65 = 80.75 -> 81)
          final nineClosures = List.generate(
            9,
            (i) => createTestDailyClosure(
              id: 'c-nine-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
              isFlaggedLocation: false,
            ),
          );
          final nineResult = CalculateFinancialPassportUseCase.computeFromData(
            closures: nineClosures,
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );
          expect(nineResult.overallScore, greaterThanOrEqualTo(80));
        },
      );

      test(
        'Scenario 3: 0 dette dans Karné Bor (25 clôtures, 0 dette créée) -> vélocité = 100%, contribution = 40 pts, score max = 100',
        () {
          final closures = List.generate(
            25,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 20000,
              cashCounted: 20000,
              isFlaggedLocation: false,
            ),
          );

          // debts: [] simule 0 dette dans le carnet
          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            debts: const [],
            asOf: now,
          );

          expect(result.breakdown.debtScore, 100);
          expect(result.breakdown.debtContribution, 40.0);
          expect(result.breakdown.closureScore, 100);
          expect(result.breakdown.closureContribution, 35.0);
          expect(result.breakdown.gpsScore, 100);
          expect(result.breakdown.gpsContribution, 15.0);
          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
          expect(result.overallScore, 100);
          expect(result.isEligible, isTrue);
          expect(result.remainingClosures, 0);
        },
      );

      test(
        'Scenario 4: 100% clôtures avec GPS hors rayon (>200m) -> gpsScore = 0%, contribution = 0 pt',
        () {
          final closures = List.generate(
            20,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
              distanceMeters: 450.0,
              isFlaggedLocation: true, // GPS hors rayon
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );

          expect(result.breakdown.gpsScore, 0);
          expect(result.breakdown.gpsContribution, 0.0);
          // 35 pts (clôtures) + 40 pts (dettes) + 0 pt (GPS) + 10 pts (cash) = 85 pts
          expect(result.overallScore, 85);
        },
      );

      test(
        'Scenario 5: Clôtures avec encaisse positive constante -> cashScore = 100%, contribution = 10 pts',
        () {
          final closures = List.generate(
            20,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 25000,
              totalExpensesAmount: 5000,
              cashCounted: 20000, // theoreticalCash = 25000 - 5000 = 20000
              isFlaggedLocation: false,
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );

          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
          expect(result.overallScore, 100);
        },
      );

      test(
        'Scenario 6: Aucune clôture enregistrée (0 clôture) -> isEligible = false, remaining = 7, message motivant',
        () {
          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: const [],
            recoveryVelocity: createTestRecoveryVelocity(rate: 100),
            asOf: now,
          );

          expect(result.isEligible, isFalse);
          expect(result.remainingClosures, 7);
          expect(result.totalClosures, 0);
          expect(result.streak, 0);
          expect(
            result.encouragementMessage,
            'Encore 7 clôtures pour débloquer votre premier passeport officiel.',
          );
          // closureScore = 0 -> 0 pt
          // debtRate = 100 -> 40.0 pts
          // gpsScore = 100 (non pénalisant) -> 15.0 pts
          // cashScore = 100 (non pénalisant) -> 10.0 pts
          // overall = 65
          expect(result.breakdown.closureScore, 0);
          expect(result.breakdown.closureContribution, 0.0);
          expect(result.breakdown.gpsScore, 100);
          expect(result.breakdown.gpsContribution, 15.0);
          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
          expect(result.overallScore, 65);
        },
      );
    });

    group('computeFromData - Edge Cases & Granular Logic', () {
      test(
        'singular unit in encouragement message when remainingClosures is exactly 1',
        () {
          final closures = List.generate(
            6,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            asOf: now,
          );

          expect(result.remainingClosures, 1);
          expect(
            result.encouragementMessage,
            'Encore 1 clôture pour débloquer votre premier passeport officiel.',
          );
        },
      );

      test('cash discipline respects 10% or 500 FCFA tolerance rule', () {
        // Closure 1: theoreticalCash = 2000, counted = 2400 (diff = 400 <= 500 F) -> consistent
        final c1 = createTestDailyClosure(
          id: 'c1',
          closureDate: '2026-11-17',
          totalSalesAmount: 2000,
          cashCounted: 2400,
        );
        // Closure 2: theoreticalCash = 20000, counted = 21500 (diff = 1500 <= 2000 F [10%]) -> consistent
        final c2 = createTestDailyClosure(
          id: 'c2',
          closureDate: '2026-11-16',
          totalSalesAmount: 20000,
          cashCounted: 21500,
        );
        // Closure 3: theoreticalCash = 20000, counted = 23000 (diff = 3000 > 2000 F) -> inconsistent
        final c3 = createTestDailyClosure(
          id: 'c3',
          closureDate: '2026-11-15',
          totalSalesAmount: 20000,
          cashCounted: 23000,
        );
        // Closure 4: cashCounted = 0 -> inconsistent
        final c4 = createTestDailyClosure(
          id: 'c4',
          closureDate: '2026-11-14',
          totalSalesAmount: 10000,
          cashCounted: 0,
        );

        final result = CalculateFinancialPassportUseCase.computeFromData(
          closures: [c1, c2, c3, c4],
          asOf: now,
        );

        // 2 consistent out of 4 -> 50%
        expect(result.breakdown.cashScore, 50);
        expect(result.breakdown.cashContribution, 5.0);
      });

      test(
        'GPS stability handles proportional score with mixed flagged closures',
        () {
          // 14 valid closures + 6 flagged closures = 20 closures (70% valid)
          final closures = [
            ...List.generate(
              14,
              (i) => createTestDailyClosure(
                id: 'c-valid-$i',
                closureDate: formatDate(now.subtract(Duration(days: i))),
                isFlaggedLocation: false,
              ),
            ),
            ...List.generate(
              6,
              (i) => createTestDailyClosure(
                id: 'c-flagged-$i',
                closureDate: formatDate(now.subtract(Duration(days: 14 + i))),
                isFlaggedLocation: true,
              ),
            ),
          ];

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            asOf: now,
          );

          // 14 / 20 = 70%
          expect(result.breakdown.gpsScore, 70);
          expect(result.breakdown.gpsContribution, 10.5);
        },
      );

      test(
        'rolling 30-day window ignores closures older than 30 days when filterByWindow is true',
        () {
          // 5 closures within window
          final inWindowClosures = List.generate(
            5,
            (i) => createTestDailyClosure(
              id: 'in-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
          );

          // 3 closures outside window (45, 50, 60 days ago)
          final outOfWindowClosures = [
            createTestDailyClosure(
              id: 'out-1',
              closureDate: formatDate(now.subtract(const Duration(days: 45))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
            createTestDailyClosure(
              id: 'out-2',
              closureDate: formatDate(now.subtract(const Duration(days: 50))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
            createTestDailyClosure(
              id: 'out-3',
              closureDate: formatDate(now.subtract(const Duration(days: 60))),
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
          ];

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: [...inWindowClosures, ...outOfWindowClosures],
            asOf: now,
            windowDays: 30,
          );

          expect(result.totalClosures, 5);
          expect(result.remainingClosures, 2);
          expect(result.isEligible, isFalse);
        },
      );

      test(
        'computes recovery velocity from debts list when recoveryVelocity is not passed',
        () {
          // 1 settled debt (50 000 F) on time + 1 overdue debt (50 000 F)
          final debtSettled = createTestDebt(
            id: 'd-settled',
            initialAmount: 50000,
            remainingAmount: 0,
            dueDate: now.subtract(const Duration(days: 5)),
            status: DebtStatus.settled,
          );
          final debtOverdue = createTestDebt(
            id: 'd-overdue',
            initialAmount: 50000,
            remainingAmount: 50000,
            dueDate: now.subtract(const Duration(days: 2)),
            status: DebtStatus.active,
          );

          final closures = List.generate(
            20,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
              cashCounted: 10000,
              totalSalesAmount: 10000,
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            debts: [debtSettled, debtOverdue],
            asOf: now,
          );

          // 50 000 F recovered on 100 000 F due = 50% velocity
          expect(result.breakdown.debtScore, 50);
          expect(result.breakdown.debtContribution, 20.0);
          // Closure 35 + Debt 20 + GPS 15 + Cash 10 = 80
          expect(result.overallScore, 80);
        },
      );

      test(
        'calculates active streak automatically when streak parameter is omitted',
        () {
          final closures = [
            createTestDailyClosure(id: 'c1', closureDate: '2026-11-17'),
            createTestDailyClosure(id: 'c2', closureDate: '2026-11-16'),
            createTestDailyClosure(id: 'c3', closureDate: '2026-11-15'),
            createTestDailyClosure(id: 'c4', closureDate: '2026-11-14'),
          ];

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            asOf: now,
          );

          expect(result.streak, 4);
        },
      );

      test('uses explicit streak when provided', () {
        final closures = [
          createTestDailyClosure(id: 'c1', closureDate: '2026-11-17'),
        ];

        final result = CalculateFinancialPassportUseCase.computeFromData(
          closures: closures,
          streak: 12,
          asOf: now,
        );

        expect(result.streak, 12);
      });

      test('entity validations reject negative numbers and validate props', () {
        final breakdown = createTestScoreBreakdown();

        expect(
          () => FinancialPassportEntity(
            overallScore: -1,
            breakdown: breakdown,
            isEligible: false,
            totalClosures: 0,
            remainingClosures: 7,
            streak: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => FinancialPassportEntity(
            overallScore: 105,
            breakdown: breakdown,
            isEligible: true,
            totalClosures: 20,
            remainingClosures: 0,
            streak: 5,
          ),
          throwsArgumentError,
        );

        expect(
          () => FinancialPassportEntity(
            overallScore: 80,
            breakdown: breakdown,
            isEligible: true,
            totalClosures: -1,
            remainingClosures: 0,
            streak: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => FinancialPassportEntity(
            overallScore: 80,
            breakdown: breakdown,
            isEligible: true,
            totalClosures: 10,
            remainingClosures: -1,
            streak: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => FinancialPassportEntity(
            overallScore: 80,
            breakdown: breakdown,
            isEligible: true,
            totalClosures: 10,
            remainingClosures: 0,
            streak: -1,
          ),
          throwsArgumentError,
        );
      });

      test('ScoreBreakdownEntity constructor validates [0, 100] bounds', () {
        expect(
          () => ScoreBreakdownEntity(
            closureScore: -1,
            debtScore: 50,
            gpsScore: 50,
            cashScore: 50,
          ),
          throwsArgumentError,
        );
        expect(
          () => ScoreBreakdownEntity(
            closureScore: 101,
            debtScore: 50,
            gpsScore: 50,
            cashScore: 50,
          ),
          throwsArgumentError,
        );
        expect(
          () => ScoreBreakdownEntity(
            closureScore: 50,
            debtScore: -5,
            gpsScore: 50,
            cashScore: 50,
          ),
          throwsArgumentError,
        );
        expect(
          () => ScoreBreakdownEntity(
            closureScore: 50,
            debtScore: 50,
            gpsScore: 150,
            cashScore: 50,
          ),
          throwsArgumentError,
        );
        expect(
          () => ScoreBreakdownEntity(
            closureScore: 50,
            debtScore: 50,
            gpsScore: 50,
            cashScore: -10,
          ),
          throwsArgumentError,
        );
      });

      test(
        'FinancialPassportEntity copyWith recomputes encouragementMessage when eligibility changes',
        () {
          final passport = FinancialPassportEntity(
            overallScore: 50,
            breakdown: createTestScoreBreakdown(closureScore: 20),
            isEligible: false,
            totalClosures: 4,
            remainingClosures: 3,
            streak: 2,
          );

          expect(
            passport.encouragementMessage,
            'Encore 3 clôtures pour débloquer votre premier passeport officiel.',
          );

          // When remainingClosures changes to 1
          final updatedRemaining = passport.copyWith(remainingClosures: 1);
          expect(
            updatedRemaining.encouragementMessage,
            'Encore 1 clôture pour débloquer votre premier passeport officiel.',
          );

          // When isEligible becomes true
          final updatedEligible = passport.copyWith(
            isEligible: true,
            remainingClosures: 0,
          );
          expect(
            updatedEligible.encouragementMessage,
            'Félicitations ! Votre passeport financier est actif et officiel.',
          );

          // When explicit message is passed, it overrides recomputation
          final customMessage = passport.copyWith(
            isEligible: true,
            encouragementMessage: 'Message personnalisé',
          );
          expect(customMessage.encouragementMessage, 'Message personnalisé');

          // When neither isEligible nor remainingClosures is passed, message remains unchanged
          final untouched = passport.copyWith(streak: 10);
          expect(
            untouched.encouragementMessage,
            'Encore 3 clôtures pour débloquer votre premier passeport officiel.',
          );
        },
      );

      test(
        'cash discipline treats cashCounted == 0 and theoreticalCash == 0 as consistent',
        () {
          // Zero day: 0 sales, 0 debt inflow, 0 expenses -> theoreticalCash = 0, cashCounted = 0
          final zeroClosure = createTestDailyClosure(
            id: 'c-zero',
            closureDate: '2026-11-17',
            totalSalesAmount: 0,
            totalExpensesAmount: 0,
            cashCounted: 0,
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: [zeroClosure],
            asOf: now,
          );

          expect(result.breakdown.cashScore, 100);
          expect(result.breakdown.cashContribution, 10.0);
        },
      );

      test(
        'multiple closures on the same day do not inflate distinct totalClosures',
        () {
          // 2 closures on 2026-11-17
          final c1 = createTestDailyClosure(
            id: 'c1',
            closureDate: '2026-11-17',
            totalSalesAmount: 5000,
            cashCounted: 5000,
          );
          final c2 = createTestDailyClosure(
            id: 'c2',
            closureDate: '2026-11-17',
            totalSalesAmount: 7000,
            cashCounted: 7000,
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: [c1, c2],
            asOf: now,
          );

          // distinct days = 1, so totalClosures = 1
          expect(result.totalClosures, 1);
          expect(result.remainingClosures, 6);
          expect(result.isEligible, isFalse);
        },
      );

      test(
        'streak calculation does not truncate streaks longer than 30 days',
        () {
          // 35 consecutive closures going back 35 days
          final closures = List.generate(
            35,
            (i) => createTestDailyClosure(
              id: 'c-$i',
              closureDate: formatDate(now.subtract(Duration(days: i))),
            ),
          );

          final result = CalculateFinancialPassportUseCase.computeFromData(
            closures: closures,
            asOf: now,
            windowDays: 30,
          );

          // Window limits totalClosures to 31 distinct days in window, but streak evaluates all closures
          expect(result.streak, 35);
        },
      );

      test(
        'ScoreBreakdownEntity copyWith and totalContribution work properly',
        () {
          final breakdown = ScoreBreakdownEntity(
            closureScore: 100,
            debtScore: 100,
            gpsScore: 100,
            cashScore: 100,
          );

          expect(breakdown.closureContribution, 35.0);
          expect(breakdown.debtContribution, 40.0);
          expect(breakdown.gpsContribution, 15.0);
          expect(breakdown.cashContribution, 10.0);
          expect(breakdown.totalContribution, 100.0);

          final updated = breakdown.copyWith(gpsScore: 50);
          expect(updated.gpsScore, 50);
          expect(updated.gpsContribution, 7.5);
        },
      );
    });
  });
}
