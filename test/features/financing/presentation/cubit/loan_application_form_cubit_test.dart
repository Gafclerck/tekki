import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/usecases/submit_loan_application_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/loan_application_form_cubit.dart';

class MockSubmitLoanApplicationUseCase extends Mock
    implements SubmitLoanApplicationUseCase {}

void main() {
  late MockSubmitLoanApplicationUseCase mockSubmitUseCase;
  late LoanApplicationFormCubit cubit;

  final partner = FinancialPartnerCatalog.defaultPartners.first;

  setUpAll(() {
    registerFallbackValue(
      LoanApplicationEntity(
        id: 'fallback',
        shopId: 'default-shop',
        partnerId: 'p1',
        partnerName: 'P1',
        requestedAmount: 100000,
        durationMonths: 3,
        monthlyPaymentEstimate: 35000,
        purpose: LoanPurpose.stock,
        status: LoanStatus.pending,
        submissionDate: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockSubmitUseCase = MockSubmitLoanApplicationUseCase();
    cubit = LoanApplicationFormCubit(
      submitLoanApplicationUseCase: mockSubmitUseCase,
      initialPartner: partner,
      initialAmount: 500000,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('LoanApplicationFormCubit Unit Tests', () {
    test(
      'initial state calculates monthly payment from initial partner and amount',
      () {
        expect(cubit.state.selectedPartner, equals(partner));
        expect(cubit.state.requestedAmount, equals(500000));
        expect(cubit.state.estimatedMonthlyPayment, greaterThan(0));
        expect(cubit.state.isValid, isTrue);
      },
    );

    test('setAmount recalculates payment', () {
      final initialPayment = cubit.state.estimatedMonthlyPayment;
      cubit.setAmount(1000000);

      expect(cubit.state.requestedAmount, equals(1000000));
      expect(cubit.state.estimatedMonthlyPayment, greaterThan(initialPayment));
    });

    test('setDuration updates duration and payment', () {
      cubit.setDuration(12);

      expect(cubit.state.durationMonths, equals(12));
    });

    test('submit succeeds and emits isSuccess true', () async {
      when(() => mockSubmitUseCase(any())).thenAnswer((invocation) async {
        final app =
            invocation.positionalArguments.first as LoanApplicationEntity;
        return Result.success(app);
      });

      await cubit.submit(shopId: 'default-shop', currentScore: 82);

      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.isSuccess, isTrue);
      expect(cubit.state.submittedApplication, isNotNull);
      verify(() => mockSubmitUseCase(any())).called(1);
    });
  });
}
