import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/location_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:uuid/uuid.dart';

class MockClosureRepository extends Mock implements ClosureRepository {}

class MockLocationService extends Mock implements ILocationService {}

class MockUuid extends Mock implements Uuid {}

class FakeDailyClosureEntity extends Fake implements DailyClosureEntity {}

void main() {
  late MockClosureRepository mockRepository;
  late MockLocationService mockLocationService;
  late MockUuid mockUuid;
  late ExecuteDailyClosureUseCase executeUseCase;
  late ExecuteDailyClosureUseCase executeUseCaseWithLocation;
  late GetClosurePrefillUseCase prefillUseCase;

  const testShopId = 'shop-tekki-1';
  final testShop = ShopEntity(
    id: testShopId,
    name: 'Boutique Sandaga',
    refLatitude: 14.67100,
    refLongitude: -17.43800,
    publicKey: 'pk-test-1234567890',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeDailyClosureEntity());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepository = MockClosureRepository();
    mockLocationService = MockLocationService();
    mockUuid = MockUuid();

    executeUseCase = ExecuteDailyClosureUseCase(
      repository: mockRepository,
      uuid: mockUuid,
    );

    executeUseCaseWithLocation = ExecuteDailyClosureUseCase(
      repository: mockRepository,
      locationService: mockLocationService,
      uuid: mockUuid,
    );

    prefillUseCase = GetClosurePrefillUseCase(repository: mockRepository);

    // Default mock behavior
    when(
      () => mockRepository.getShopById(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockRepository.getShop(),
    ).thenAnswer((_) async => const Success(null));
  });

  const testClosureId = '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d';

  group('ExecuteDailyClosureUseCase - Core & Amounts', () {
    test(
      'successfully executes closure with nominal amounts and default date',
      () async {
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
      },
    );

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

    test(
      'rejects negative totalExpensesAmount with ValidationFailure',
      () async {
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
            expect(
              failure.message,
              contains('dépenses ne peut pas être négatif'),
            );
          },
        );
        verifyZeroInteractions(mockRepository);
      },
    );

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
          expect(
            failure.message,
            contains('espèces comptées ne peut pas être négatif'),
          );
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

  group(
    'ExecuteDailyClosureUseCase - Passive Geofencing & Silent Flagging (Story 1.5)',
    () {
      test(
        'nominal on-site closure (< 200m) records coords, distance, and is_flagged_location: false',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById(testShopId),
          ).thenAnswer((_) async => Success(testShop));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          // Captured position ~35m North of shop (14.671315, -17.43800)
          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer(
            (_) async =>
                const GeoLocation(latitude: 14.671315, longitude: -17.43800),
          );

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.gpsLatitude, equals(14.671315));
              expect(closure.gpsLongitude, equals(-17.43800));
              expect(closure.distanceMeters, isNotNull);
              expect(closure.distanceMeters!, greaterThan(34.0));
              expect(closure.distanceMeters!, lessThan(36.0));
              expect(
                closure.distanceMeters!,
                lessThanOrEqualTo(AppConstants.shopGeofenceRadiusMeters),
              );
              expect(closure.isFlaggedLocation, isFalse);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'off-site closure (> 200m) records coords, distance, and silent is_flagged_location: true',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById(testShopId),
          ).thenAnswer((_) async => Success(testShop));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          // Position ~450m East of shop (14.67100, -17.433814)
          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer(
            (_) async =>
                const GeoLocation(latitude: 14.67100, longitude: -17.433814),
          );

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.gpsLatitude, equals(14.67100));
              expect(closure.gpsLongitude, equals(-17.433814));
              expect(closure.distanceMeters, isNotNull);
              expect(closure.distanceMeters!, greaterThan(440.0));
              expect(
                closure.distanceMeters!,
                greaterThan(AppConstants.shopGeofenceRadiusMeters),
              );
              expect(closure.isFlaggedLocation, isTrue);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'GPS timeout or unavailable: coords and distance are null, is_flagged_location: true',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          // Simulates 5s timeout or disabled sensor returning null
          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer((_) async => null);

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.gpsLatitude, isNull);
              expect(closure.gpsLongitude, isNull);
              expect(closure.distanceMeters, isNull);
              expect(closure.isFlaggedLocation, isTrue);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'GPS permission denied: silent is_flagged_location: true, completes without error',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer((_) async => null);

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.isFlaggedLocation, isTrue);
              expect(closure.gpsLatitude, isNull);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'Shop not found in local DB: records GPS coords, distance null, is_flagged_location: true',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById('unknown-shop'),
          ).thenAnswer((_) async => const Success(null));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer(
            (_) async =>
                const GeoLocation(latitude: 14.6937, longitude: -17.4441),
          );

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: 'unknown-shop',
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.gpsLatitude, equals(14.6937));
              expect(closure.gpsLongitude, equals(-17.4441));
              expect(closure.distanceMeters, isNull);
              expect(closure.isFlaggedLocation, isTrue);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'falls back to getShop() when getShopById returns null and calculates distance',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById('unmatched-shop-id'),
          ).thenAnswer((_) async => const Success(null));
          when(
            () => mockRepository.getShop(),
          ).thenAnswer((_) async => Success(testShop));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          when(
            () => mockLocationService.getCurrentLocation(
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer(
            (_) async =>
                const GeoLocation(latitude: 14.671315, longitude: -17.43800),
          );

          final result = await executeUseCaseWithLocation(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: 'unmatched-shop-id',
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.isFlaggedLocation, isFalse);
              expect(closure.distanceMeters, isNotNull);
              expect(
                closure.distanceMeters!,
                lessThanOrEqualTo(AppConstants.shopGeofenceRadiusMeters),
              );
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'flags location if calculated or passed distance is NaN or Infinite',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById(testShopId),
          ).thenAnswer((_) async => Success(testShop));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          final result = await executeUseCase(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
            gpsLatitude: 14.671,
            gpsLongitude: -17.438,
            distanceMeters: double.nan,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.isFlaggedLocation, isTrue);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );

      test(
        'manual GPS coords in call parameters are respected when locationService is null',
        () async {
          when(() => mockUuid.v4()).thenReturn(testClosureId);
          when(
            () => mockRepository.getShopById(testShopId),
          ).thenAnswer((_) async => Success(testShop));
          when(() => mockRepository.executeDailyClosure(any())).thenAnswer(
            (invocation) async => Success(
              invocation.positionalArguments[0] as DailyClosureEntity,
            ),
          );

          final result = await executeUseCase(
            cutoffTimestamp: DateTime.now(),
            totalSalesAmount: 15000,
            shopId: testShopId,
            gpsLatitude: 14.671315,
            gpsLongitude: -17.43800,
          );

          expect(result.isSuccess, isTrue);
          result.fold(
            onSuccess: (closure) {
              expect(closure.gpsLatitude, equals(14.671315));
              expect(closure.gpsLongitude, equals(-17.43800));
              expect(closure.distanceMeters, isNotNull);
              expect(closure.isFlaggedLocation, isFalse);
            },
            onError: (_) => fail('Should not fail'),
          );
        },
      );
    },
  );

  group('GetClosurePrefillUseCase', () {
    test(
      'calls repository with UTC timestamp and returns prefill amount',
      () async {
        final localCutoff = DateTime(2026, 11, 17, 18, 0);
        when(
          () => mockRepository.getPrefillSalesAmount(localCutoff.toUtc()),
        ).thenAnswer((_) async => const Success(45000));

        final result = await prefillUseCase(localCutoff);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (amount) => expect(amount, equals(45000)),
          onError: (_) => fail('Should not fail'),
        );

        verify(
          () => mockRepository.getPrefillSalesAmount(localCutoff.toUtc()),
        ).called(1);
      },
    );

    test('propagates repository failure', () async {
      final localCutoff = DateTime(2026, 11, 17, 18, 0);
      when(
        () => mockRepository.getPrefillSalesAmount(localCutoff.toUtc()),
      ).thenAnswer(
        (_) async => const Error(DatabaseFailure(message: 'Query error')),
      );

      final result = await prefillUseCase(localCutoff);

      expect(result.isError, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should not succeed'),
        onError: (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, equals('Query error'));
        },
      );
    });
  });
}
