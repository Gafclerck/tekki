import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';
import 'package:tekki/features/financing/domain/usecases/evaluate_loan_eligibility_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/get_financial_partners_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/watch_loan_applications_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_cubit.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_state.dart';

class MockGetFinancialPartnersUseCase extends Mock
    implements GetFinancialPartnersUseCase {}

class MockEvaluateLoanEligibilityUseCase extends Mock
    implements EvaluateLoanEligibilityUseCase {}

class MockWatchLoanApplicationsUseCase extends Mock
    implements WatchLoanApplicationsUseCase {}

class MockPassportRepository extends Mock implements PassportRepository {}

void main() {
  late MockGetFinancialPartnersUseCase mockPartnersUseCase;
  late MockEvaluateLoanEligibilityUseCase mockEligibilityUseCase;
  late MockWatchLoanApplicationsUseCase mockWatchAppsUseCase;
  late MockPassportRepository mockPassportRepo;
  late FinancingCubit cubit;

  const partners = FinancialPartnerCatalog.defaultPartners;
  const testEligibility = LoanEligibilityEntity(
    isEligible: true,
    maxBorrowingCapacity: 1500000,
    currentScore: 82,
    closuresCount: 14,
    grade: 'A+',
    statusSummary: 'Éligible',
    eligiblePartnerIds: ['baobab_sn', 'cofina_sn'],
  );

  setUp(() {
    mockPartnersUseCase = MockGetFinancialPartnersUseCase();
    mockEligibilityUseCase = MockEvaluateLoanEligibilityUseCase();
    mockWatchAppsUseCase = MockWatchLoanApplicationsUseCase();
    mockPassportRepo = MockPassportRepository();

    cubit = FinancingCubit(
      getFinancialPartnersUseCase: mockPartnersUseCase,
      evaluateLoanEligibilityUseCase: mockEligibilityUseCase,
      watchLoanApplicationsUseCase: mockWatchAppsUseCase,
      passportRepository: mockPassportRepo,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('FinancingCubit Unit Tests', () {
    test('initial state has status initial', () {
      expect(cubit.state.status, equals(FinancingStatus.initial));
      expect(cubit.state.partners, isEmpty);
      expect(cubit.state.applications, isEmpty);
    });

    test(
      'loadFinancingData loads partners, evaluates eligibility, and listens to apps stream',
      () async {
        when(() => mockPartnersUseCase()).thenAnswer((_) async => partners);
        when(() => mockPassportRepo.getFinancialPassport()).thenAnswer(
          (_) async => Result.success(
            FinancialPassportEntity(
              overallScore: 82,
              isEligible: true,
              totalClosures: 14,
              remainingClosures: 0,
              streak: 14,
              breakdown: ScoreBreakdownEntity(
                closureScore: 85,
                debtScore: 80,
                gpsScore: 100,
                cashScore: 90,
              ),
              calculatedAt: DateTime.now(),
            ),
          ),
        );
        when(
          () => mockEligibilityUseCase(
            passport: any(named: 'passport'),
            partners: partners,
          ),
        ).thenReturn(testEligibility);
        when(
          () => mockWatchAppsUseCase(shopId: 'default-shop'),
        ).thenAnswer((_) => Stream.value([]));

        await cubit.loadFinancingData(shopId: 'default-shop');

        expect(cubit.state.status, equals(FinancingStatus.loaded));
        expect(cubit.state.partners, equals(partners));
        expect(cubit.state.eligibility, equals(testEligibility));
      },
    );

    test('selectPartner updates selectedPartner', () {
      cubit.selectPartner(partners.first);
      expect(cubit.state.selectedPartner, equals(partners.first));

      cubit.selectPartner(null);
      expect(cubit.state.selectedPartner, isNull);
    });
  });
}
