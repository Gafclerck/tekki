import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/repositories/sales_repository_impl.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

class MockSalesLocalDataSource extends Mock implements SalesLocalDataSource {}

void main() {
  late MockSalesLocalDataSource mockDataSource;
  late SalesRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockSalesLocalDataSource();
    repository = SalesRepositoryImpl(localDataSource: mockDataSource);
  });

  final testSale = SaleEntity(
    id: 'sale-uuid-1',
    amount: 5000,
    paymentMethod: PaymentMethod.especes,
    recordedAt: DateTime(2026, 11, 17, 8, 0),
  );

  group('SalesRepositoryImpl', () {
    test('recordSale returns Success(sale) when data source insertion succeeds', () async {
      when(() => mockDataSource.insertSale(testSale)).thenAnswer((_) async {});

      final result = await repository.recordSale(testSale);

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (sale) => expect(sale, equals(testSale)),
        onError: (_) => fail('Should not fail'),
      );
      verify(() => mockDataSource.insertSale(testSale)).called(1);
    });

    test('recordSale returns DatabaseFailure when data source throws DatabaseException', () async {
      when(() => mockDataSource.insertSale(testSale)).thenThrow(
        const DatabaseException('SQLite write error'),
      );

      final result = await repository.recordSale(testSale);

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, equals('SQLite write error'));
        },
      );
    });

    test('getSaleById returns Success(sale)', () async {
      when(() => mockDataSource.getSaleById('sale-uuid-1')).thenAnswer(
        (_) async => testSale,
      );

      final result = await repository.getSaleById('sale-uuid-1');

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (sale) => expect(sale, equals(testSale)),
        onError: (_) => fail('Should not fail'),
      );
    });

    test('getAllSales returns Success(list)', () async {
      when(() => mockDataSource.getAllSales(limit: 50, offset: null)).thenAnswer(
        (_) async => [testSale],
      );

      final result = await repository.getAllSales();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (sales) => expect(sales, equals([testSale])),
        onError: (_) => fail('Should not fail'),
      );
    });

    test('getOrphanSales returns Success(list)', () async {
      when(() => mockDataSource.getOrphanSales()).thenAnswer(
        (_) async => [testSale],
      );

      final result = await repository.getOrphanSales();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (sales) => expect(sales, equals([testSale])),
        onError: (_) => fail('Should not fail'),
      );
    });

    test('watchOrphanSales delegates directly to data source stream', () {
      when(() => mockDataSource.watchOrphanSales()).thenAnswer(
        (_) => Stream.value([testSale]),
      );

      final stream = repository.watchOrphanSales();

      expect(stream, emits([testSale]));
      verify(() => mockDataSource.watchOrphanSales()).called(1);
    });
  });
}
