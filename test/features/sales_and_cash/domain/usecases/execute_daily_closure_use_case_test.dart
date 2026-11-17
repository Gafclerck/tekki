import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:uuid/uuid.dart';

class MockClosureRepository extends Mock implements ClosureRepository {}
class MockUuid extends Mock implements Uuid {}
class FakeDailyClosureEntity extends Fake implements DailyClosureEntity {}

void main() {
  late MockClosureRepository mockRepository;
  late MockUuid mockUuid;
  late ExecuteDailyClosureUseCase executeUseCase;
  late GetClosurePrefillUseCase prefillUseCase;

  setUpAll(() {
    registerFallbackValue(FakeDailyClosureEntity());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepository = MockClosureRepository();
    mockUuid = MockUuid();
    executeUseCase = ExecuteDailyClosureUseCase(
      repository: mockRepository,
      uuid: mockUuid,
    );
    prefillUseCase = GetClosurePrefillUseCase(repository: mockRepository);
  });

  const testClosureId = '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d';

  group('ExecuteDailyClosureUseCase', () {
    test('successfully executes closure with nominal amounts and default date', () async {
      when(() => mockUuid.v4()).thenReturn(testClosureId);
      when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
        (invocation) async =>
            Success(invocation.positionalArguments[0] as DailyClosureEntity),
      );

      final cutoff = DateTime(2026, 11, 17, 21, 30);
      final result = await executeUseCase(
        cutoffTimestamp: cutoff,
        totalSalesAmount: 17500,
        totalExpensesAmount: 2500,
        cashCounted: 15000,
        shopId: 'shop-tekki-1',
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (closure) {
          expect(closure.id, equals(testClosureId));
          expect(closure.shopId, equals('shop-tekki-1'));
          expect(closure.closureDate, equals('2026-11-17'));
          expect(closure.cutoffTimestamp.isUtc, isTrue);
          expect(closure.totalSalesAmount, equals(17500));
          expect(closure.totalExpensesAmount, equals(2500));
          expect(closure.cashCounted, equals(15000));
          expect(closure.theoreticalCash, equals(15000));
          expect(closure.difference, equals(0));
          expect(closure.syncStatus, equals('pending'));
        },
        onError: (_) => fail('Should not fail'),
      );

      verify(() => mockRepository.executeDailyClosure(any())).called(1);
    });

    test('successfully executes adjusted sales amount closure', () async {
      when(() => mockUuid.v4()).thenReturn(testClosureId);
      when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
        (invocation) async =>
            Success(invocation.positionalArguments[0] as DailyClosureEntity),
      );

      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: 108500,
        totalExpensesAmount: 15000,
        cashCounted: 93500,
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (closure) {
          expect(closure.totalSalesAmount, equals(108500));
          expect(closure.totalExpensesAmount, equals(15000));
          expect(closure.cashCounted, equals(93500));
        },
        onError: (_) => fail('Should not fail'),
      );
    });

    test('successfully executes zero sales day closure', () async {
      when(() => mockUuid.v4()).thenReturn(testClosureId);
      when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
        (invocation) async =>
            Success(invocation.positionalArguments[0] as DailyClosureEntity),
      );

      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: 0,
        totalExpensesAmount: 0,
        cashCounted: 0,
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (closure) {
          expect(closure.totalSalesAmount, equals(0));
        },
        onError: (_) => fail('Should not fail'),
      );
    });

    test('rejects negative totalSalesAmount with ValidationFailure', () async {
      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: -100,
      );

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('ventes ne peut pas être négatif'));
        },
      );
      verifyZeroInteractions(mockRepository);
    });

    test('rejects negative totalExpensesAmount with ValidationFailure', () async {
      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: 5000,
        totalExpensesAmount: -200,
      );

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('dépenses ne peut pas être négatif'));
        },
      );
      verifyZeroInteractions(mockRepository);
    });

    test('rejects negative cashCounted with ValidationFailure', () async {
      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: 5000,
        cashCounted: -100,
      );

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('espèces comptées ne peut pas être négatif'));
        },
      );
      verifyZeroInteractions(mockRepository);
    });

    test('propagates DatabaseFailure on repository failure', () async {
      when(() => mockUuid.v4()).thenReturn(testClosureId);
      when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Disk error')),
      );

      final result = await executeUseCase(
        cutoffTimestamp: DateTime.now(),
        totalSalesAmount: 5000,
      );

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, equals('Disk error'));
        },
      );
    });
  });

  group('GetClosurePrefillUseCase', () {
    test('calls repository with UTC timestamp and returns prefill amount', () async {
      final localCutoff = DateTime(2026, 11, 17, 18, 0);
      when(() => mockRepository.getPrefillSalesAmount(any())).thenAnswer(
        (_) async => const Success(17500),
      );

      final result = await prefillUseCase(localCutoff);

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (amount) => expect(amount, equals(17500)),
        onError: (_) => fail('Should not fail'),
      );

      verify(() => mockRepository.getPrefillSalesAmount(localCutoff.toUtc())).called(1);
    });

    test('propagates repository DatabaseFailure on error', () async {
      when(() => mockRepository.getPrefillSalesAmount(any())).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Query failed')),
      );

      final result = await prefillUseCase(DateTime(2026, 11, 17, 18, 0));

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, equals('Query failed'));
        },
      );
    });
  });
}
