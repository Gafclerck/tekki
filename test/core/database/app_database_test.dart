import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/models/sale_model.dart';
import 'package:tekki/features/sales_and_cash/data/models/shop_model.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart';
import 'package:tekki/injection_container.dart' as di;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase database;
  late SalesLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SalesLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase Initialization & Pragmas', () {
    test('Applies WAL, NORMAL, and foreign_keys pragmas during opening',
        () async {
      final syncResult = await database.customSelect(
        'PRAGMA synchronous;',
      ).getSingle();
      // NORMAL corresponds to synchronous = 1
      expect(syncResult.data['synchronous'], equals(1));

      final fkResult = await database.customSelect(
        'PRAGMA foreign_keys;',
      ).getSingle();
      // foreign_keys = 1 when ON
      expect(fkResult.data['foreign_keys'], equals(1));
    });

    test('WAL pragma persists on a file-backed database', () async {
      final tempDir = await Directory.systemTemp.createTemp('tekki_db_test_');
      final dbFile = File('${tempDir.path}/test_tekki.sqlite');
      final diskDb = AppDatabase.forTesting(NativeDatabase(dbFile));

      try {
        final journalResult = await diskDb.customSelect(
          'PRAGMA journal_mode;',
        ).getSingle();
        expect(
          journalResult.data['journal_mode'].toString().toLowerCase(),
          equals('wal'),
        );

        final syncResult = await diskDb.customSelect(
          'PRAGMA synchronous;',
        ).getSingle();
        expect(syncResult.data['synchronous'], equals(1));

        final fkResult = await diskDb.customSelect(
          'PRAGMA foreign_keys;',
        ).getSingle();
        expect(fkResult.data['foreign_keys'], equals(1));
      } finally {
        await diskDb.close();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('Tables shops and sales exist in SQLite schema', () async {
      final tables = await database.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table';",
      ).get();

      final tableNames =
          tables.map((row) => row.data['name'] as String).toSet();
      expect(tableNames.contains('shops'), isTrue);
      expect(tableNames.contains('sales'), isTrue);
    });

    test('Indexes sales_closure_id_idx and sales_sync_status_idx exist on sales',
        () async {
      final indexes = await database.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index';",
      ).get();

      final indexNames =
          indexes.map((row) => row.data['name'] as String).toSet();
      expect(indexNames.contains('sales_closure_id_idx'), isTrue);
      expect(indexNames.contains('sales_sync_status_idx'), isTrue);
    });
  });

  group('Shop Operations', () {
    test('Inserts a shop and retrieves it successfully', () async {
      final shop = ShopEntity(
        id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Boutique Touba Sandaga',
        refLatitude: 14.6737,
        refLongitude: -17.4372,
        publicKey: 'ed25519-public-key-hex-sample',
        createdAt: DateTime.parse('2026-11-17T07:00:00.000Z'),
      );

      await dataSource.insertShop(shop);

      final retrieved = await dataSource.getShopById(shop.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(shop.id));
      expect(retrieved.name, equals('Boutique Touba Sandaga'));
      expect(retrieved.refLatitude, equals(14.6737));
      expect(retrieved.refLongitude, equals(-17.4372));
      expect(retrieved.publicKey, equals('ed25519-public-key-hex-sample'));
      expect(retrieved.syncStatus, equals('pending'));
      expect(
        retrieved.createdAt.toIso8601String(),
        equals('2026-11-17T07:00:00.000Z'),
      );
    });

    test('Duplicate Shop UUID throws DatabaseException', () async {
      final shop = ShopEntity(
        id: 'shop-uuid-duplicate',
        name: 'Boutique 1',
        refLatitude: 14.67,
        refLongitude: -17.43,
        publicKey: 'key-1',
        createdAt: DateTime.now().toUtc(),
      );

      await dataSource.insertShop(shop);

      expect(
        () => dataSource.insertShop(shop),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('ShopEntity rejects missing mandatory fields', () {
      expect(
        () => ShopEntity(
          id: '',
          name: 'Valid Name',
          refLatitude: 14.0,
          refLongitude: -17.0,
          publicKey: 'key',
          createdAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ShopEntity(
          id: 'valid-id',
          name: '',
          refLatitude: 14.0,
          refLongitude: -17.0,
          publicKey: 'key',
          createdAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ShopEntity(
          id: 'valid-id',
          name: 'Valid Name',
          refLatitude: 14.0,
          refLongitude: -17.0,
          publicKey: '',
          createdAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'ShopEntity rejects out-of-range or NaN coordinates and normalizes createdAt to UTC',
        () {
      final localDate = DateTime.parse('2026-11-17 10:00:00');
      final shop = ShopEntity(
        id: 'shop-valid-utc',
        name: 'Valid Shop',
        refLatitude: 14.0,
        refLongitude: -17.0,
        publicKey: 'key',
        createdAt: localDate,
      );
      expect(shop.createdAt.isUtc, isTrue);

      expect(
        () => ShopEntity(
          id: 'shop-inv-lat',
          name: 'Shop',
          refLatitude: 95.0,
          refLongitude: 0.0,
          publicKey: 'key',
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ShopEntity(
          id: 'shop-inv-lat-nan',
          name: 'Shop',
          refLatitude: double.nan,
          refLongitude: 0.0,
          publicKey: 'key',
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => ShopEntity(
          id: 'shop-inv-lng',
          name: 'Shop',
          refLatitude: 0.0,
          refLongitude: 185.0,
          publicKey: 'key',
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Watch shop emits stream updates reactively', () async {
      final shop = ShopEntity(
        id: 'shop-stream-test',
        name: 'Boutique Stream',
        refLatitude: 14.7,
        refLongitude: -17.4,
        publicKey: 'pubkey-123',
        createdAt: DateTime.now().toUtc(),
      );

      final expectation = expectLater(
        dataSource.watchShop(),
        emitsInOrder([
          isNull,
          predicate<ShopEntity?>((s) => s != null && s.id == shop.id),
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await dataSource.insertShop(shop);

      await expectation;
    });

    test('ShopModel.toEntity() produces a genuine ShopEntity with Equatable equality',
        () {
      final now = DateTime.now().toUtc();
      final model = ShopModel(
        id: 'shop-model-1',
        name: 'Shop 1',
        refLatitude: 14.5,
        refLongitude: -17.2,
        publicKey: 'key-1',
        syncStatus: 'pending',
        createdAt: now,
      );

      final entity = model.toEntity();
      expect(entity.runtimeType, equals(ShopEntity));
      expect(
        entity,
        equals(
          ShopEntity(
            id: 'shop-model-1',
            name: 'Shop 1',
            refLatitude: 14.5,
            refLongitude: -17.2,
            publicKey: 'key-1',
            syncStatus: 'pending',
            createdAt: now,
          ),
        ),
      );
    });
  });

  group('Sale Operations', () {
    test(
        'Inserts a quick sale with default closure_id null and sync_status pending',
        () async {
      final recordedAt = DateTime.parse('2026-11-17T07:15:00.000Z');
      final sale = SaleEntity(
        id: 'sale-uuid-quick-1',
        amount: 5000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: recordedAt,
      );

      await dataSource.insertSale(sale);

      final retrieved = await dataSource.getSaleById(sale.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(sale.id));
      expect(retrieved.amount, equals(5000));
      expect(retrieved.paymentMethod, equals(PaymentMethod.especes));
      expect(retrieved.recordedAt, equals(recordedAt));
      expect(retrieved.closureId, isNull);
      expect(retrieved.syncStatus, equals('pending'));
      expect(retrieved.lastSyncedAt, isNull);
    });

    test('Rejects invalid or non-positive sale amount at entity level', () {
      expect(
        () => SaleEntity(
          id: 'sale-invalid-amount-1',
          amount: 0,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => SaleEntity(
          id: 'sale-invalid-amount-2',
          amount: -2500,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => SaleEntity(
          id: '   ',
          amount: 5000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime.now().toUtc(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'SaleEntity rejects whitespace-only closureId and normalizes timestamps to UTC',
        () {
      final localRecordedAt = DateTime.parse('2026-11-17 12:00:00');
      final localSyncedAt = DateTime.parse('2026-11-17 12:05:00');
      final sale = SaleEntity(
        id: 'sale-valid',
        amount: 1000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: localRecordedAt,
        lastSyncedAt: localSyncedAt,
      );
      expect(sale.recordedAt.isUtc, isTrue);
      expect(sale.lastSyncedAt?.isUtc, isTrue);

      expect(
        () => SaleEntity(
          id: 'sale-inv-closure',
          amount: 1000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime.now(),
          closureId: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Filters orphan sales where closure_id IS NULL and uses index in < 50ms',
        () async {
      // Empty check
      final initialOrphans = await dataSource.getOrphanSales();
      expect(initialOrphans, isEmpty);

      final now = DateTime.now().toUtc();
      // Insert 10 orphan sales and 5 closed sales
      for (var i = 0; i < 10; i++) {
        await dataSource.insertSale(
          SaleEntity(
            id: 'orphan-sale-$i',
            amount: 1000 + (i * 500),
            paymentMethod: i.isEven
                ? PaymentMethod.especes
                : PaymentMethod.mobileMoney,
            recordedAt: now.add(Duration(minutes: i)),
            closureId: null,
          ),
        );
      }

      for (var i = 0; i < 5; i++) {
        await dataSource.insertSale(
          SaleEntity(
            id: 'closed-sale-$i',
            amount: 2000,
            paymentMethod: PaymentMethod.creditClient,
            recordedAt: now.subtract(Duration(hours: 1, minutes: i)),
            closureId: 'daily-closure-uuid-yesterday',
          ),
        );
      }

      final stopwatch = Stopwatch()..start();
      final orphans = await dataSource.getOrphanSales();
      stopwatch.stop();

      expect(orphans.length, equals(10));
      expect(orphans.every((s) => s.closureId == null), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test(
        'getAllSales and watchAllSales reject non-positive limit and support pagination',
        () async {
      expect(
        () => dataSource.getAllSales(limit: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => dataSource.getAllSales(limit: -5),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => dataSource.watchAllSales(limit: 0),
        throwsA(isA<ArgumentError>()),
      );

      final now = DateTime.now().toUtc();
      for (var i = 0; i < 5; i++) {
        await dataSource.insertSale(
          SaleEntity(
            id: 'page-sale-$i',
            amount: (i + 1) * 1000,
            paymentMethod: PaymentMethod.especes,
            recordedAt: now.add(Duration(minutes: i)),
          ),
        );
      }

      final paged = await dataSource.getAllSales(limit: 2, offset: 1);
      expect(paged.length, equals(2));
    });

    test('Watch orphan sales emits reactively on new sale insertion', () async {
      final now = DateTime.now().toUtc();
      final sale1 = SaleEntity(
        id: 'watch-orphan-1',
        amount: 3000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: now,
      );
      final sale2 = SaleEntity(
        id: 'watch-orphan-2',
        amount: 7500,
        paymentMethod: PaymentMethod.mobileMoney,
        recordedAt: now.add(const Duration(seconds: 10)),
      );

      final expectation = expectLater(
        dataSource.watchOrphanSales(),
        emitsInOrder([
          isEmpty,
          hasLength(1),
          hasLength(2),
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await dataSource.insertSale(sale1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await dataSource.insertSale(sale2);

      await expectation;
    });

    test('PaymentMethod string conversions are bidirectional and normalized',
        () {
      expect(PaymentMethod.especes.toValue(), 'ESPECES');
      expect(PaymentMethod.mobileMoney.toValue(), 'MOBILE_MONEY');
      expect(PaymentMethod.creditClient.toValue(), 'CREDIT_CLIENT');

      expect(PaymentMethod.fromValue('especes'), PaymentMethod.especes);
      expect(
        PaymentMethod.fromValue('MOBILE_MONEY'),
        PaymentMethod.mobileMoney,
      );
      expect(
        PaymentMethod.fromValue('credit-client'),
        PaymentMethod.creditClient,
      );

      expect(
        () => PaymentMethod.fromValue('BITCOIN'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('SaleModel.toEntity() produces a genuine SaleEntity with Equatable equality',
        () {
      final now = DateTime.now().toUtc();
      final model = SaleModel(
        id: 'sale-model-1',
        amount: 2500,
        paymentMethod: PaymentMethod.especes,
        recordedAt: now,
        closureId: 'closure-1',
        syncStatus: 'pending',
        lastSyncedAt: now,
      );

      final entity = model.toEntity();
      expect(entity.runtimeType, equals(SaleEntity));
      expect(
        entity,
        equals(
          SaleEntity(
            id: 'sale-model-1',
            amount: 2500,
            paymentMethod: PaymentMethod.especes,
            recordedAt: now,
            closureId: 'closure-1',
            syncStatus: 'pending',
            lastSyncedAt: now,
          ),
        ),
      );
    });

    test('SaleModel.fromJson parses amount from num safely', () {
      final json = {
        'id': 'sale-json-1',
        'amount': 5000.0,
        'payment_method': 'ESPECES',
        'recorded_at': '2026-11-17T08:00:00.000Z',
      };
      final model = SaleModel.fromJson(json);
      expect(model.amount, equals(5000));
    });
  });

  group('Dependency Injection (get_it)', () {
    test('Registers AppDatabase and SalesLocalDataSource without domain leakage',
        () async {
      await di.sl.reset();
      await di.initDependencyInjection(inMemoryDatabase: true);

      expect(di.sl.isRegistered<AppDatabase>(), isTrue);
      expect(di.sl.isRegistered<SalesLocalDataSource>(), isTrue);
      expect(di.sl.isRegistered<ClosureLocalDataSource>(), isTrue);
      expect(di.sl.isRegistered<ClosureRepository>(), isTrue);
      expect(di.sl.isRegistered<GetClosurePrefillUseCase>(), isTrue);
      expect(di.sl.isRegistered<ExecuteDailyClosureUseCase>(), isTrue);
      expect(di.sl.isRegistered<ExpressClosureCubit>(), isTrue);

      final resolvedDb = di.sl<AppDatabase>();
      expect(resolvedDb, isA<AppDatabase>());

      final resolvedDs = di.sl<SalesLocalDataSource>();
      expect(resolvedDs, isA<SalesLocalDataSource>());

      final resolvedClosureDs = di.sl<ClosureLocalDataSource>();
      expect(resolvedClosureDs, isA<ClosureLocalDataSource>());

      final resolvedClosureCubit = di.sl<ExpressClosureCubit>();
      expect(resolvedClosureCubit, isA<ExpressClosureCubit>());

      await di.sl.reset();
    });
  });
}
