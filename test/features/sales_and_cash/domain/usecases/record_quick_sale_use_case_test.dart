import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:uuid/uuid.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

class MockUuid extends Mock implements Uuid {}

class FakeSaleEntity extends Fake implements SaleEntity {}

void main() {
  late MockSalesRepository mockRepository;
  late MockUuid mockUuid;
  late RecordQuickSaleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeSaleEntity());
  });

  setUp(() {
    mockRepository = MockSalesRepository();
    mockUuid = MockUuid();
    useCase = RecordQuickSaleUseCase(
      repository: mockRepository,
      uuid: mockUuid,
    );
  });

  const testId = '4f8e0255-7578-43d9-9524-7ef26629ec88';

  group('RecordQuickSaleUseCase', () {
    test('successfully records a quick sale with default cash payment and UTC date', () async {
      when(() => mockUuid.v4()).thenReturn(testId);
      when(() => mockRepository.recordSale(any())).thenAnswer(
        (invocation) async =>
            Success(invocation.positionalArguments[0] as SaleEntity),
      );

      final now = DateTime(2026, 11, 17, 10, 30);
      final result = await useCase(amount: 5000, recordedAt: now);

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (sale) {
          expect(sale.id, equals(testId));
          expect(sale.amount, equals(5000));
          expect(sale.paymentMethod, equals(PaymentMethod.especes));
          expect(sale.closureId, isNull);
          expect(sale.syncStatus, equals('pending'));
          expect(sale.recordedAt.isUtc, isTrue);
          expect(sale.recordedAt, equals(now.toUtc()));
        },
        onError: (_) => fail('Should not fail'),
      );

      verify(() => mockRepository.recordSale(any())).called(1);
    });

    test(
      'successfully records a quick sale with Mobile Money payment method',
      () async {
        when(() => mockUuid.v4()).thenReturn(testId);
        when(() => mockRepository.recordSale(any())).thenAnswer(
          (invocation) async =>
              Success(invocation.positionalArguments[0] as SaleEntity),
        );

        final result = await useCase(
          amount: 1500,
          paymentMethod: PaymentMethod.mobileMoney,
        );

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (sale) {
            expect(sale.amount, equals(1500));
            expect(sale.paymentMethod, equals(PaymentMethod.mobileMoney));
          },
          onError: (_) => fail('Should not fail'),
        );
      },
    );

    test('returns ValidationFailure when amount is 0', () async {
      final result = await useCase(amount: 0);

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('strictement supérieur à zéro'));
        },
      );
      verifyZeroInteractions(mockRepository);
    });

    test('returns ValidationFailure when amount is negative', () async {
      final result = await useCase(amount: -500);

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<ValidationFailure>());
        },
      );
      verifyZeroInteractions(mockRepository);
    });

    test(
      'returns ValidationFailure when amount exceeds 999 999 999 FCFA',
      () async {
        final result = await useCase(amount: 1000000000);

        expect(result.isError, isTrue);
        result.fold(
          onSuccess: (_) => fail('Should not succeed'),
          onError: (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('plafond'));
          },
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('propagates DatabaseFailure when repository fails', () async {
      when(() => mockUuid.v4()).thenReturn(testId);
      when(() => mockRepository.recordSale(any())).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Disk I/O error')),
      );

      final result = await useCase(amount: 2500);

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, equals('Disk I/O error'));
        },
      );
    });
  });
}
