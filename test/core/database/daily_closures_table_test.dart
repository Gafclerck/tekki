import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/models/daily_closure_model.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase database;
  late SalesLocalDataSource salesDataSource;
  late ClosureLocalDataSource closureDataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    salesDataSource = SalesLocalDataSourceImpl(database: database);
    closureDataSource = ClosureLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DailyClosures Table & Schema Integration', () {
    test('daily_closures table and indexes exist in SQLite schema', () async {
      final tables = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type='table';")
          .get();
      final tableNames = tables
          .map((row) => row.data['name'] as String)
          .toSet();
      expect(tableNames.contains('daily_closures'), isTrue);

      final indexes = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type='index';")
          .get();
      final indexNames = indexes
          .map((row) => row.data['name'] as String)
          .toSet();
      expect(indexNames.contains('daily_closures_date_idx'), isTrue);
      expect(indexNames.contains('daily_closures_sync_status_idx'), isTrue);
    });

    test('DailyClosureEntity validations reject invalid arguments', () {
      final now = DateTime.now().toUtc();

      // Empty id
      expect(
        () => DailyClosureEntity(
          id: '',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Empty shopId
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: '',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Empty closureDate
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Negative sales amount
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Negative expenses
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
          totalExpensesAmount: -50,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Negative cash counted
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
          cashCounted: -100,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Invalid GPS
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
          gpsLatitude: 95.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
          gpsLongitude: 200.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DailyClosureEntity(
          id: 'closure-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: now,
          totalSalesAmount: 1000,
          distanceMeters: -5.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'DailyClosureEntity normalizes timestamps to UTC and computes reconciliation',
      () {
        final localCutoff = DateTime(2026, 11, 17, 20, 0);
        final entity = DailyClosureEntity(
          id: 'closure-reconcile-test',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: localCutoff,
          totalSalesAmount: 17500,
          totalExpensesAmount: 2500,
          cashCounted: 15000,
        );

        expect(entity.cutoffTimestamp.isUtc, isTrue);
        expect(entity.createdAt.isUtc, isTrue);
        expect(entity.theoreticalCash, equals(15000));
        expect(entity.difference, equals(0));
      },
    );

    test('DailyClosureModel conversions are bidirectional and normalized', () {
      final now = DateTime.now().toUtc();
      final model = DailyClosureModel(
        id: 'closure-conv-1',
        shopId: 'shop-conv',
        closureDate: '2026-11-17',
        cutoffTimestamp: now,
        totalSalesAmount: 108500,
        totalExpensesAmount: 15000,
        cashCounted: 93500,
        gpsLatitude: 14.7167,
        gpsLongitude: -17.4677,
        distanceMeters: 42.5,
        isFlaggedLocation: false,
        syncStatus: 'pending',
        createdAt: now,
      );

      final json = model.toJson();
      final fromJson = DailyClosureModel.fromJson(json);
      expect(fromJson.id, equals(model.id));
      expect(fromJson.totalSalesAmount, equals(108500));
      expect(fromJson.gpsLatitude, closeTo(14.7167, 0.0001));

      final driftCompanion = model.toCompanion();
      expect(driftCompanion.id.value, equals(model.id));
      expect(driftCompanion.totalSalesAmount.value, equals(108500));

      final driftRow = model.toDrift();
      expect(driftRow.id, equals(model.id));
      expect(driftRow.toEntity().id, equals(model.id));
    });
  });

  group('Atomic Snapshotting & Closure Operations', () {
    test(
      'Prefill calculates exact sum of orphan sales before or at cutoff',
      () async {
        final t0 = DateTime(2026, 11, 17, 10, 0).toUtc();
        final cutoff = DateTime(2026, 11, 17, 12, 0).toUtc();
        final tAfter = DateTime(2026, 11, 17, 12, 30).toUtc();

        // Sale 1: before cutoff, orphan (10 000)
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's1',
            amount: 10000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: t0,
          ),
        );

        // Sale 2: before cutoff, orphan (5 000)
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's2',
            amount: 5000,
            paymentMethod: PaymentMethod.mobileMoney,
            recordedAt: cutoff, // exactly at cutoff
          ),
        );

        // Sale 3: after cutoff, orphan (7 000)
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's3',
            amount: 7000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: tAfter,
          ),
        );

        // Sale 4: before cutoff, but already closed (3 000)
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's4',
            amount: 3000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: t0,
            closureId: 'previous-closure',
          ),
        );

        final prefill = await closureDataSource.getPrefillSalesAmount(cutoff);
        // Expected sum: 10000 + 5000 = 15000
        expect(prefill, equals(15000));
      },
    );

    test(
      'Nominal closure: atomic transaction seals orphan sales and inserts daily_closures',
      () async {
        final cutoff = DateTime(2026, 11, 17, 18, 0).toUtc();

        // Insert 3 orphan sales: 10 000, 5 000, 2 500 = 17 500
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-nom-1',
            amount: 10000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: DateTime(2026, 11, 17, 14, 0).toUtc(),
          ),
        );
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-nom-2',
            amount: 5000,
            paymentMethod: PaymentMethod.mobileMoney,
            recordedAt: DateTime(2026, 11, 17, 15, 0).toUtc(),
          ),
        );
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-nom-3',
            amount: 2500,
            paymentMethod: PaymentMethod.especes,
            recordedAt: DateTime(2026, 11, 17, 17, 0).toUtc(),
          ),
        );

        final closure = DailyClosureEntity(
          id: 'closure-nom-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: 17500,
          totalExpensesAmount: 2500,
          cashCounted: 15000,
        );

        final result = await closureDataSource.executeDailyClosure(closure);
        expect(result.id, equals('closure-nom-1'));

        // Check daily_closures row in DB
        final retrievedClosure = await closureDataSource.getClosureById(
          'closure-nom-1',
        );
        expect(retrievedClosure, isNotNull);
        expect(retrievedClosure!.totalSalesAmount, equals(17500));
        expect(retrievedClosure.totalExpensesAmount, equals(2500));
        expect(retrievedClosure.cashCounted, equals(15000));

        // Verify all 3 sales are now sealed with closure_id
        final s1 = await salesDataSource.getSaleById('s-nom-1');
        final s2 = await salesDataSource.getSaleById('s-nom-2');
        final s3 = await salesDataSource.getSaleById('s-nom-3');

        expect(s1!.closureId, equals('closure-nom-1'));
        expect(s2!.closureId, equals('closure-nom-1'));
        expect(s3!.closureId, equals('closure-nom-1'));

        // Orphan sales query now returns empty
        final orphans = await salesDataSource.getOrphanSales();
        expect(orphans, isEmpty);
      },
    );

    test(
      'Concurrent sale post-cutoff remains strictly orphan (isolation temporelle)',
      () async {
        final cutoff = DateTime(2026, 11, 17, 18, 0).toUtc();
        final postCutoffTime = DateTime(2026, 11, 17, 18, 5).toUtc();

        // Sale before cutoff
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-pre',
            amount: 8000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: DateTime(2026, 11, 17, 17, 50).toUtc(),
          ),
        );

        // Sale after cutoff (arrived while closure was in progress)
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-post',
            amount: 5000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: postCutoffTime,
          ),
        );

        final closure = DailyClosureEntity(
          id: 'closure-iso-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: 8000,
          totalExpensesAmount: 0,
          cashCounted: 8000,
        );

        await closureDataSource.executeDailyClosure(closure);

        // Pre-cutoff sale is sealed
        final preSale = await salesDataSource.getSaleById('s-pre');
        expect(preSale!.closureId, equals('closure-iso-1'));

        // Post-cutoff sale remains orphan!
        final postSale = await salesDataSource.getSaleById('s-post');
        expect(postSale!.closureId, isNull);

        final orphans = await salesDataSource.getOrphanSales();
        expect(orphans.length, equals(1));
        expect(orphans.first.id, equals('s-post'));
      },
    );

    test(
      'Zero sales day: completes closure without error and without modifying any sales',
      () async {
        final cutoff = DateTime(2026, 11, 17, 21, 0).toUtc();

        final closure = DailyClosureEntity(
          id: 'closure-zero-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: 0,
          totalExpensesAmount: 500,
          cashCounted: 0,
        );

        final result = await closureDataSource.executeDailyClosure(closure);
        expect(result.id, equals('closure-zero-1'));

        final retrieved = await closureDataSource.getClosureById(
          'closure-zero-1',
        );
        expect(retrieved, isNotNull);
        expect(retrieved!.totalSalesAmount, equals(0));
        expect(retrieved.totalExpensesAmount, equals(500));
      },
    );

    test(
      'Rollback on failure: database error does not seal any sales',
      () async {
        final cutoff = DateTime(2026, 11, 17, 18, 0).toUtc();

        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-rollback',
            amount: 12000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: DateTime(2026, 11, 17, 17, 0).toUtc(),
          ),
        );

        // Attempting to insert a duplicate closure id will fail on primary key
        final closure1 = DailyClosureEntity(
          id: 'closure-dup-id',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: 12000,
        );
        await closureDataSource.executeDailyClosure(closure1);

        // Sale is now sealed by closure1
        final sale = await salesDataSource.getSaleById('s-rollback');
        expect(sale!.closureId, equals('closure-dup-id'));

        // New sale
        await salesDataSource.insertSale(
          SaleEntity(
            id: 's-rollback-2',
            amount: 6000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: DateTime(2026, 11, 17, 17, 30).toUtc(),
          ),
        );

        // Duplicate closure insertion should throw DatabaseException
        final closureDuplicate = DailyClosureEntity(
          id: 'closure-dup-id', // duplicate PK
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: 6000,
        );

        expect(
          () => closureDataSource.executeDailyClosure(closureDuplicate),
          throwsA(isA<DatabaseException>()),
        );

        // Verify s-rollback-2 was NOT sealed and remains orphan due to rollback
        final s2 = await salesDataSource.getSaleById('s-rollback-2');
        expect(s2!.closureId, isNull);
      },
    );

    test(
      'getAllClosures supports pagination and order by createdAt desc',
      () async {
        final now = DateTime.now().toUtc();
        for (var i = 1; i <= 5; i++) {
          await closureDataSource.executeDailyClosure(
            DailyClosureEntity(
              id: 'closure-page-$i',
              shopId: 'shop-1',
              closureDate: '2026-11-$i',
              cutoffTimestamp: now.add(Duration(days: i)),
              totalSalesAmount: i * 1000,
              createdAt: now.add(Duration(hours: i)),
            ),
          );
        }

        final page1 = await closureDataSource.getAllClosures(
          limit: 2,
          offset: 0,
        );
        expect(page1.length, equals(2));
        expect(page1.first.id, equals('closure-page-5'));

        final page2 = await closureDataSource.getAllClosures(
          limit: 2,
          offset: 2,
        );
        expect(page2.length, equals(2));
        expect(page2.first.id, equals('closure-page-3'));
      },
    );

    test('getMonthlyClosuresCount returns correct count for month', () async {
      final now = DateTime.utc(2026, 11, 15);
      await closureDataSource.executeDailyClosure(
        DailyClosureEntity(
          id: 'c-nov-1',
          shopId: 'shop-1',
          closureDate: '2026-11-10',
          cutoffTimestamp: now,
          totalSalesAmount: 5000,
        ),
      );
      await closureDataSource.executeDailyClosure(
        DailyClosureEntity(
          id: 'c-nov-2',
          shopId: 'shop-1',
          closureDate: '2026-11-11',
          cutoffTimestamp: now,
          totalSalesAmount: 7000,
        ),
      );
      await closureDataSource.executeDailyClosure(
        DailyClosureEntity(
          id: 'c-oct-1',
          shopId: 'shop-1',
          closureDate: '2026-10-31',
          cutoffTimestamp: now,
          totalSalesAmount: 3000,
        ),
      );

      final novCount = await closureDataSource.getMonthlyClosuresCount(
        DateTime.utc(2026, 11, 1),
        shopId: 'shop-1',
      );
      expect(novCount, equals(2));

      final octCount = await closureDataSource.getMonthlyClosuresCount(
        DateTime.utc(2026, 10, 1),
        shopId: 'shop-1',
      );
      expect(octCount, equals(1));

      final decCount = await closureDataSource.getMonthlyClosuresCount(
        DateTime.utc(2026, 12, 1),
        shopId: 'shop-1',
      );
      expect(decCount, equals(0));
    });

    test(
      'getActiveStreak calculates consecutive closure days accurately',
      () async {
        final ref = DateTime.utc(2026, 11, 17);
        // Three consecutive days: Nov 15, Nov 16, Nov 17
        await closureDataSource.executeDailyClosure(
          DailyClosureEntity(
            id: 'c-streak-1',
            shopId: 'shop-streak',
            closureDate: '2026-11-15',
            cutoffTimestamp: ref,
            totalSalesAmount: 5000,
          ),
        );
        await closureDataSource.executeDailyClosure(
          DailyClosureEntity(
            id: 'c-streak-2',
            shopId: 'shop-streak',
            closureDate: '2026-11-16',
            cutoffTimestamp: ref,
            totalSalesAmount: 6000,
          ),
        );
        await closureDataSource.executeDailyClosure(
          DailyClosureEntity(
            id: 'c-streak-3',
            shopId: 'shop-streak',
            closureDate: '2026-11-17',
            cutoffTimestamp: ref,
            totalSalesAmount: 8000,
          ),
        );

        final streak = await closureDataSource.getActiveStreak(
          referenceDate: ref,
          shopId: 'shop-streak',
        );
        expect(streak, equals(3));

        // Before closing today (Nov 17): if today is not closed, streak is 2 (from yesterday)
        final streakBeforeToday = await closureDataSource.getActiveStreak(
          referenceDate: DateTime.utc(
            2026,
            11,
            18,
          ), // Nov 18 not closed yet, Nov 17 was closed
          shopId: 'shop-streak',
        );
        expect(streakBeforeToday, equals(3)); // Nov 17, 16, 15

        // Missing days breaks streak
        final streakBroken = await closureDataSource.getActiveStreak(
          referenceDate: DateTime.utc(2026, 11, 20), // Nov 19 & 20 not closed
          shopId: 'shop-streak',
        );
        expect(streakBroken, equals(0));
      },
    );

    test('getShopById returns shop entity from shops table', () async {
      final shop = ShopEntity(
        id: 'shop-anchor-1',
        name: 'Boutique Plateau',
        refLatitude: 14.6710,
        refLongitude: -17.4380,
        publicKey: 'pk-test',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await salesDataSource.insertShop(shop);

      final fetched = await closureDataSource.getShopById('shop-anchor-1');
      expect(fetched, isNotNull);
      expect(fetched?.id, equals('shop-anchor-1'));
      expect(fetched?.refLatitude, equals(14.6710));

      final unknown = await closureDataSource.getShopById('non-existent');
      expect(unknown, isNull);
    });
  });
}
