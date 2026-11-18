import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';
import 'package:tekki/features/financing/domain/usecases/submit_loan_application_use_case.dart';

class MockLoanApplicationRepository extends Mock
    implements LoanApplicationRepository {}

void main() {
  late MockLoanApplicationRepository mockRepo;
  late SubmitLoanApplicationUseCase useCase;

  final validApplication = LoanApplicationEntity(
    id: 'app-1',
    shopId: 'default-shop',
    partnerId: 'baobab_sn',
    partnerName: 'Baobab Sénégal',
    requestedAmount: 500000,
    durationMonths: 6,
    monthlyPaymentEstimate: 92500,
    purpose: LoanPurpose.stock,
    status: LoanStatus.pending,
    submissionDate: DateTime.now(),
    passportScoreAtSubmission: 82,
  );

  setUpAll(() {
    registerFallbackValue(validApplication);
  });

  setUp(() {
    mockRepo = MockLoanApplicationRepository();
    useCase = SubmitLoanApplicationUseCase(repository: mockRepo);
  });

  group('SubmitLoanApplicationUseCase Unit Tests', () {
    test('rejects application with amount <= 0', () async {
      final invalid = validApplication.copyWith(requestedAmount: 0);

      final result = await useCase(invalid);

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure.message,
        contains('strictement supérieur à 0'),
      );
      verifyNever(() => mockRepo.submitApplication(any()));
    });

    test('rejects application with duration <= 0', () async {
      final invalid = validApplication.copyWith(durationMonths: 0);

      final result = await useCase(invalid);

      expect(result.isError, isTrue);
      expect((result as Error).failure.message, contains('au moins 1 mois'));
      verifyNever(() => mockRepo.submitApplication(any()));
    });

    test('rejects application with empty partner id', () async {
      final invalid = validApplication.copyWith(partnerId: '   ');

      final result = await useCase(invalid);

      expect(result.isError, isTrue);
      expect(
        (result as Error).failure.message,
        contains('partenaire financier doit être sélectionné'),
      );
      verifyNever(() => mockRepo.submitApplication(any()));
    });

    test(
      'delegates to repository and returns success for valid application',
      () async {
        when(
          () => mockRepo.submitApplication(validApplication),
        ).thenAnswer((_) async => Result.success(validApplication));

        final result = await useCase(validApplication);

        expect(result.isSuccess, isTrue);
        expect((result as Success).data, equals(validApplication));
        verify(() => mockRepo.submitApplication(validApplication)).called(1);
      },
    );
  });
}
