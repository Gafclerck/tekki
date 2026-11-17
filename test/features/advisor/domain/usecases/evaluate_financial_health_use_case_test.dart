import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';
import 'package:tekki/features/advisor/domain/usecases/evaluate_financial_health_use_case.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAdvisorRepository mockRepository;
  late EvaluateFinancialHealthUseCase useCase;

  final fixedNow = DateTime.utc(2026, 11, 17, 12, 0);

  setUp(() {
    mockRepository = MockAdvisorRepository();
    useCase = EvaluateFinancialHealthUseCase(repository: mockRepository);
  });

  group('EvaluateFinancialHealthUseCase call method', () {
    test('delegates call directly to AdvisorRepository', () async {
      final expectedHealth = createTestFinancialHealth();
      when(
        () => mockRepository.evaluateFinancialHealth(
          asOf: any(named: 'asOf'),
          windowDays: any(named: 'windowDays'),
        ),
      ).thenAnswer((_) async => Success(expectedHealth));

      final result = await useCase(asOf: fixedNow, windowDays: 30);

      expect(result, isA<Success<FinancialHealthEntity, Failure>>());
      expect(
        (result as Success<FinancialHealthEntity, Failure>).data,
        equals(expectedHealth),
      );
      verify(
        () => mockRepository.evaluateFinancialHealth(
          asOf: fixedNow,
          windowDays: 30,
        ),
      ).called(1);
    });
  });

  group('Deterministic Audit Engine (I/O & Edge-Case Matrix)', () {
    test('Scenario 1: Base vide / Nouveau commercant (0 cloture, 0 dette)', () {
      final health = EvaluateFinancialHealthUseCase.computeFromData(
        closures: [],
        debts: [],
        asOf: fixedNow,
        isNewShop: true,
      );

      expect(health.overallStatus, equals(HealthStatus.conforme));
      expect(health.indicators.length, equals(4));

      final caisse = health.caisseRegularity;
      expect(caisse, isNotNull);
      expect(caisse!.status, equals(HealthStatus.conforme));
      expect(caisse.diagnostic, contains('Bienvenue sur Tekki'));
      expect(caisse.recommendation, contains('première clôture express'));

      final karneBor = health.karneBorRecovery;
      expect(karneBor, isNotNull);
      expect(karneBor!.status, equals(HealthStatus.conforme));

      final cash = health.cashDiscipline;
      expect(cash, isNotNull);
      expect(cash!.status, equals(HealthStatus.conforme));

      final location = health.locationStability;
      expect(location, isNotNull);
      expect(location!.status, equals(HealthStatus.conforme));
    });

    test(
      'Scenario 2: Clotures quotidiennes regulieres & 0 dette en retard (Happy Path)',
      () {
        // 20 clôtures consécutives sans écart ni flag GPS
        final closures = List.generate(20, (i) {
          final d = fixedNow.subtract(Duration(days: i));
          final dateStr =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          return createTestDailyClosure(
            id: 'closure-$i',
            closureDate: dateStr,
            createdAt: d,
            totalSalesAmount: 25000,
            cashCounted: 25000,
            isFlaggedLocation: false,
          );
        });

        final health = EvaluateFinancialHealthUseCase.computeFromData(
          closures: closures,
          debts: [],
          asOf: fixedNow,
        );

        expect(health.overallStatus, equals(HealthStatus.conforme));
        expect(health.caisseRegularity!.status, equals(HealthStatus.conforme));
        expect(health.caisseRegularity!.diagnostic, contains('discipline'));
        expect(health.karneBorRecovery!.status, equals(HealthStatus.conforme));
        expect(health.cashDiscipline!.status, equals(HealthStatus.conforme));
        expect(health.locationStability!.status, equals(HealthStatus.conforme));
        expect(health.summary, contains('Bravo'));
      },
    );

    test(
      'Scenario 3: Dettes anciennes en souffrance (> 30 jours sans remboursement)',
      () {
        final overdueDebt = DebtEntity(
          id: 'overdue-1',
          debtorId: 'debtor-1',
          initialAmount: 20000,
          remainingAmount: 20000,
          status: DebtStatus.active,
          dueDate: fixedNow.subtract(const Duration(days: 35)),
          createdAt: fixedNow.subtract(const Duration(days: 45)),
        );

        final health = EvaluateFinancialHealthUseCase.computeFromData(
          closures: [
            createTestDailyClosure(
              id: 'c-1',
              closureDate: '2026-11-17',
              createdAt: fixedNow,
              totalSalesAmount: 10000,
              cashCounted: 10000,
            ),
          ],
          debts: [overdueDebt],
          recoveryVelocity: const RecoveryVelocityEntity(
            rate: 30,
            totalDueAmount: 20000,
            totalRecoveredAmount: 0,
            healthStatus: 'Critique',
          ),
          asOf: fixedNow,
        );

        expect(health.karneBorRecovery!.status, equals(HealthStatus.urgent));
        expect(
          health.karneBorRecovery!.diagnostic,
          contains('30 jours de retard'),
        );
        expect(health.karneBorRecovery!.recommendation, contains('WhatsApp'));
        expect(health.overallStatus, equals(HealthStatus.urgent));
        expect(health.summary, contains('Attention requise'));
      },
    );

    test('Scenario 4: Clotures irregulieres (3 a 6 clotures sur 30 jours)', () {
      final closures = List.generate(4, (i) {
        final d = fixedNow.subtract(Duration(days: i));
        final dateStr =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return createTestDailyClosure(
          id: 'closure-$i',
          closureDate: dateStr,
          createdAt: d,
          totalSalesAmount: 10000,
          cashCounted: 10000,
        );
      });

      final health = EvaluateFinancialHealthUseCase.computeFromData(
        closures: closures,
        debts: [],
        asOf: fixedNow,
      );

      expect(health.caisseRegularity!.status, equals(HealthStatus.attention));
      expect(health.caisseRegularity!.diagnostic, contains('4 fois'));
      expect(health.overallStatus, equals(HealthStatus.attention));
    });

    test('Scenario 5: Aucune cloture depuis plus de 3 jours', () {
      final oldClosure = createTestDailyClosure(
        id: 'old-closure',
        closureDate: '2026-11-12',
        createdAt: fixedNow.subtract(const Duration(days: 5)),
        totalSalesAmount: 15000,
        cashCounted: 15000,
      );

      final health = EvaluateFinancialHealthUseCase.computeFromData(
        closures: [oldClosure],
        debts: [],
        asOf: fixedNow,
      );

      expect(health.caisseRegularity!.status, equals(HealthStatus.urgent));
      expect(health.caisseRegularity!.diagnostic, contains('plus de 3 jours'));
      expect(health.overallStatus, equals(HealthStatus.urgent));
    });

    test(
      'Scenario 6: Ecarts de caisse frequents (cashCounted != theoreticalCash)',
      () {
        // 10 clôtures dont 5 avec un écart supérieur à la tolérance (50% de discordance)
        final closures = List.generate(10, (i) {
          final d = fixedNow.subtract(Duration(days: i));
          final hasDiscrepancy = i < 5;
          return createTestDailyClosure(
            id: 'closure-$i',
            closureDate:
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
            createdAt: d,
            totalSalesAmount: 20000,
            cashCounted: hasDiscrepancy ? 12000 : 20000, // 8000 FCFA d'écart
          );
        });

        final health = EvaluateFinancialHealthUseCase.computeFromData(
          closures: closures,
          debts: [],
          asOf: fixedNow,
        );

        expect(health.cashDiscipline!.status, equals(HealthStatus.urgent));
        expect(health.cashDiscipline!.diagnostic, contains('écarts de caisse'));
      },
    );

    test(
      'Scenario 7: Clotures hors du point de vente (isFlaggedLocation == true)',
      () {
        // 10 clôtures dont 6 avec isFlaggedLocation = true (60%)
        final closures = List.generate(10, (i) {
          final d = fixedNow.subtract(Duration(days: i));
          final isFlagged = i < 6;
          return createTestDailyClosure(
            id: 'closure-$i',
            closureDate:
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
            createdAt: d,
            totalSalesAmount: 10000,
            cashCounted: 10000,
            isFlaggedLocation: isFlagged,
          );
        });

        final health = EvaluateFinancialHealthUseCase.computeFromData(
          closures: closures,
          debts: [],
          asOf: fixedNow,
        );

        expect(health.locationStability!.status, equals(HealthStatus.urgent));
        expect(
          health.locationStability!.diagnostic,
          contains('hors du périmètre'),
        );
      },
    );

    test('Moderate debt delay (7 to 30 days) yields status attention', () {
      final moderateDebt = DebtEntity(
        id: 'mod-1',
        debtorId: 'debtor-1',
        initialAmount: 15000,
        remainingAmount: 10000,
        status: DebtStatus.active,
        dueDate: fixedNow.subtract(const Duration(days: 12)),
        createdAt: fixedNow.subtract(const Duration(days: 20)),
      );

      final health = EvaluateFinancialHealthUseCase.computeFromData(
        closures: List.generate(10, (i) {
          final d = fixedNow.subtract(Duration(days: i));
          return createTestDailyClosure(
            id: 'c-$i',
            closureDate:
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
            createdAt: d,
            totalSalesAmount: 10000,
            cashCounted: 10000,
          );
        }),
        debts: [moderateDebt],
        recoveryVelocity: const RecoveryVelocityEntity(
          rate: 65,
          totalDueAmount: 15000,
          totalRecoveredAmount: 5000,
          healthStatus: 'Attention',
        ),
        asOf: fixedNow,
      );

      expect(health.karneBorRecovery!.status, equals(HealthStatus.attention));
      expect(
        health.karneBorRecovery!.diagnostic,
        contains('Certains règlements'),
      );
    });
  });
}
