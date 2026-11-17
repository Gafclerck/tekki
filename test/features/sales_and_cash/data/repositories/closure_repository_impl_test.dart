import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/repositories/closure_repository_impl.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

class MockClosureLocalDataSource extends Mock
    implements ClosureLocalDataSource {}

void main() {
  late MockClosureLocalDataSource mockDataSource;
  late ClosureRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockClosureLocalDataSource();
    repository = ClosureRepositoryImpl(localDataSource: mockDataSource);
  });

  final cutoff = DateTime(2026, 11, 17, 21, 0).toUtc();
  final testClosure = DailyClosureEntity(
    id: 'closure-repo-test-1',
    shopId: 'shop-repo-1',
    closureDate: '2026-11-17',
    cutoffTimestamp: cutoff,
    totalSalesAmount: 17500,
    totalExpensesAmount: 2500,
    cashCounted: 15000,
  );

  group('ClosureRepositoryImpl', () {
    group('getPrefillSalesAmount', () {
      test('returns Success(amount) when data source succeeds', () async {
        when(
          () => mockDataSource.getPrefillSalesAmount(cutoff),
        ).thenAnswer((_) async => 17500);

        final result = await repository.getPrefillSalesAmount(cutoff);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (amount) => expect(amount, equals(17500)),
          onError: (_) => fail('Should not fail'),
        );
        verify(() => mockDataSource.getPrefillSalesAmount(cutoff)).called(1);
      });

      test(
        'returns DatabaseFailure when data source throws DatabaseException',
        () async {
          when(
            () => mockDataSource.getPrefillSalesAmount(cutoff),
          ).thenThrow(const DatabaseException('SQLite query error'));

          final result = await repository.getPrefillSalesAmount(cutoff);

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, equals('SQLite query error'));
            },
          );
        },
      );

      test(
        'returns DatabaseFailure when an unexpected exception occurs',
        () async {
          when(
            () => mockDataSource.getPrefillSalesAmount(cutoff),
          ).thenThrow(Exception('Unexpected crash'));

          final result = await repository.getPrefillSalesAmount(cutoff);

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, contains('Erreur inattendue'));
            },
          );
        },
      );
    });

    group('executeDailyClosure', () {
      test('returns Success(closure) when transaction succeeds', () async {
        when(
          () => mockDataSource.executeDailyClosure(testClosure),
        ).thenAnswer((_) async => testClosure);

        final result = await repository.executeDailyClosure(testClosure);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (closure) => expect(closure, equals(testClosure)),
          onError: (_) => fail('Should not fail'),
        );
        verify(() => mockDataSource.executeDailyClosure(testClosure)).called(1);
      });

      test(
        'returns DatabaseFailure when transaction throws DatabaseException',
        () async {
          when(() => mockDataSource.executeDailyClosure(testClosure)).thenThrow(
            const DatabaseException('Transaction rollback: disk full'),
          );

          final result = await repository.executeDailyClosure(testClosure);

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, contains('Transaction rollback'));
            },
          );
        },
      );

      test(
        'returns DatabaseFailure when an unexpected exception occurs',
        () async {
          when(
            () => mockDataSource.executeDailyClosure(testClosure),
          ).thenThrow(Exception('Unexpected write error'));

          final result = await repository.executeDailyClosure(testClosure);

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, contains('Erreur inattendue'));
            },
          );
        },
      );
    });

    group('getClosureById', () {
      test('returns Success(closure) when closure is found', () async {
        when(
          () => mockDataSource.getClosureById('closure-repo-test-1'),
        ).thenAnswer((_) async => testClosure);

        final result = await repository.getClosureById('closure-repo-test-1');

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (closure) => expect(closure, equals(testClosure)),
          onError: (_) => fail('Should not fail'),
        );
      });

      test('returns Success(null) when closure is not found', () async {
        when(
          () => mockDataSource.getClosureById('non-existent'),
        ).thenAnswer((_) async => null);

        final result = await repository.getClosureById('non-existent');

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (closure) => expect(closure, isNull),
          onError: (_) => fail('Should not fail'),
        );
      });

      test(
        'returns DatabaseFailure when data source throws DatabaseException',
        () async {
          when(
            () => mockDataSource.getClosureById('any-id'),
          ).thenThrow(const DatabaseException('Database read error'));

          final result = await repository.getClosureById('any-id');

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, equals('Database read error'));
            },
          );
        },
      );
    });

    group('getAllClosures', () {
      test('returns Success(list) with pagination', () async {
        when(
          () => mockDataSource.getAllClosures(limit: 10, offset: 5),
        ).thenAnswer((_) async => [testClosure]);

        final result = await repository.getAllClosures(limit: 10, offset: 5);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (list) => expect(list, equals([testClosure])),
          onError: (_) => fail('Should not fail'),
        );
      });

      test(
        'returns DatabaseFailure when data source throws DatabaseException',
        () async {
          when(
            () => mockDataSource.getAllClosures(limit: 50, offset: null),
          ).thenThrow(const DatabaseException('Pagination error'));

          final result = await repository.getAllClosures();

          expect(result.isError, isTrue);
          result.fold(
            onSuccess: (_) => fail('Should not succeed'),
            onError: (failure) {
              expect(failure, isA<DatabaseFailure>());
              expect(failure.message, equals('Pagination error'));
            },
          );
        },
      );
    });
  });
}
