import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/data/datasources/loan_application_local_data_source.dart';
import 'package:tekki/features/financing/data/repositories/loan_application_repository_impl.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';

class MockLoanApplicationLocalDataSource extends Mock
    implements LoanApplicationLocalDataSource {}

void main() {
  late MockLoanApplicationLocalDataSource mockDataSource;
  late LoanApplicationRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockLoanApplicationLocalDataSource();
    repository = LoanApplicationRepositoryImpl(dataSource: mockDataSource);
  });

  final testApp = LoanApplicationEntity(
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
    passportScoreAtSubmission: 80,
  );

  group('LoanApplicationRepositoryImpl Unit Tests', () {
    test('submitApplication succeeds and returns Result.success', () async {
      when(
        () => mockDataSource.insertApplication(testApp),
      ).thenAnswer((_) async {});

      final result = await repository.submitApplication(testApp);

      expect(result.isSuccess, isTrue);
      expect((result as Success).data, equals(testApp));
      verify(() => mockDataSource.insertApplication(testApp)).called(1);
    });

    test(
      'submitApplication handles DatabaseException and returns Result.failure',
      () async {
        when(
          () => mockDataSource.insertApplication(testApp),
        ).thenThrow(const DatabaseException('SQLite write failure'));

        final result = await repository.submitApplication(testApp);

        expect(result.isError, isTrue);
        expect(
          (result as Error).failure.message,
          contains('SQLite write failure'),
        );
      },
    );

    test('watchApplications forwards reactive stream from datasource', () {
      when(
        () => mockDataSource.watchApplications(shopId: 'default-shop'),
      ).thenAnswer((_) => Stream.value([testApp]));

      final stream = repository.watchApplications(shopId: 'default-shop');

      expect(stream, emits([testApp]));
      verify(
        () => mockDataSource.watchApplications(shopId: 'default-shop'),
      ).called(1);
    });

    test('getApplications delegates to datasource', () async {
      when(
        () => mockDataSource.getApplications(shopId: 'default-shop'),
      ).thenAnswer((_) async => [testApp]);

      final result = await repository.getApplications(shopId: 'default-shop');

      expect(result, equals([testApp]));
      verify(
        () => mockDataSource.getApplications(shopId: 'default-shop'),
      ).called(1);
    });
  });
}
