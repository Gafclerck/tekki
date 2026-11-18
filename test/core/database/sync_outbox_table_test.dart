import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

void main() {
  late AppDatabase db;
  late SalesLocalDataSource salesDataSource;
  late ClosureLocalDataSource closureDataSource;
  late DebtLocalDataSource debtDataSource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    salesDataSource = SalesLocalDataSourceImpl(database: db);
    closureDataSource = ClosureLocalDataSourceImpl(database: db);
    debtDataSource = DebtLocalDataSourceImpl(database: db);

    // Seed a shop
    await salesDataSource.insertShop(
      ShopEntity(
        id: 'shop-test-1',
        name: 'Keur Commercant',
        refLatitude: 14.6710,
        refLongitude: -17.4380,
        publicKey: 'pk-test',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncOutbox Table & Schema Verification', () {
    test('Table sync_outbox and indexes exist in SQLite schema', () async {
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='sync_outbox';",
          )
          .get();
      expect(tables, hasLength(1));
      expect(tables.first.data['name'], 'sync_outbox');

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='sync_outbox';",
          )
          .get();
      final indexNames = indexes.map((i) => i.data['name']).toList();
      expect(indexNames, contains('sync_outbox_status_idx'));
      expect(indexNames, contains('sync_outbox_created_at_idx'));
    });
  });

  group('Atomic Outbox Insertion on Business Mutations', () {
    test(
      'insertSale atomically inserts into sales and sync_outbox with PENDING status',
      () async {
        final sale = SaleEntity(
          id: 'sale-test-uuid',
          amount: 5000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime.utc(2026, 11, 18, 12, 0),
        );

        await salesDataSource.insertSale(sale);

        // Verify sale row
        final retrievedSale = await salesDataSource.getSaleById(
          'sale-test-uuid',
        );
        expect(retrievedSale, isNotNull);
        expect(retrievedSale!.amount, 5000);
        expect(retrievedSale.syncStatus, 'pending');

        // Verify outbox row
        final outboxRows = await db.select(db.syncOutbox).get();
        expect(outboxRows, hasLength(1));
        final event = outboxRows.first;
        expect(event.eventType, 'SALE_CREATED');
        expect(event.targetTable, 'sales');
        expect(event.targetId, 'sale-test-uuid');
        expect(event.status, 'PENDING');
        expect(event.retryCount, 0);
        expect(event.clientEventId, isNotEmpty);
        expect(event.payloadJson, contains('5000'));
      },
    );

    test(
      'executeDailyClosure atomically inserts into daily_closures and sync_outbox',
      () async {
        final closure = DailyClosureEntity(
          id: 'closure-test-uuid',
          shopId: 'shop-test-1',
          closureDate: '2026-11-18',
          cutoffTimestamp: DateTime.utc(2026, 11, 18, 20, 0),
          totalSalesAmount: 15000,
          totalCashDebtInflow: 5000,
          totalCreditSalesAmount: 0,
          totalExpensesAmount: 0,
          cashCounted: 20000,
          createdAt: DateTime.utc(2026, 11, 18, 20, 5),
        );

        await closureDataSource.executeDailyClosure(closure);

        // Verify closure row
        final retrieved = await closureDataSource.getClosureById(
          'closure-test-uuid',
        );
        expect(retrieved, isNotNull);
        expect(retrieved!.cashCounted, 20000);

        // Verify outbox row
        final outboxRows = await (db.select(
          db.syncOutbox,
        )..where((tbl) => tbl.eventType.equals('CLOSURE_SUBMITTED'))).get();
        expect(outboxRows, hasLength(1));
        final event = outboxRows.first;
        expect(event.targetTable, 'daily_closures');
        expect(event.targetId, 'closure-test-uuid');
        expect(event.status, 'PENDING');
        expect(event.payloadJson, contains('closure-test-uuid'));
      },
    );

    test(
      'recordDebtWithDebtor atomically inserts debtor, debt and both outbox events',
      () async {
        final debtor = DebtorEntity(
          id: 'debtor-test-uuid',
          name: 'Fatou Sow',
          phoneNumber: '+221770001122',
          createdAt: DateTime.utc(2026, 11, 18, 14, 0),
        );
        final debt = DebtEntity(
          id: 'debt-test-uuid',
          debtorId: 'debtor-test-uuid',
          initialAmount: 10000,
          remainingAmount: 10000,
          dueDate: DateTime.utc(2026, 11, 25),
          createdAt: DateTime.utc(2026, 11, 18, 14, 0),
          status: DebtStatus.active,
        );

        await debtDataSource.recordDebtWithDebtor(
          debtor: debtor,
          debt: debt,
          isNewDebtor: true,
        );

        // Verify debtor and debt
        final retrievedDebtor = await debtDataSource.getDebtorById(
          'debtor-test-uuid',
        );
        expect(retrievedDebtor, isNotNull);
        final retrievedDebt = await debtDataSource.getDebtById(
          'debt-test-uuid',
        );
        expect(retrievedDebt, isNotNull);

        // Verify outbox rows
        final debtorEvents = await (db.select(
          db.syncOutbox,
        )..where((tbl) => tbl.eventType.equals('DEBTOR_CREATED'))).get();
        expect(debtorEvents, hasLength(1));
        expect(debtorEvents.first.targetId, 'debtor-test-uuid');

        final debtEvents = await (db.select(
          db.syncOutbox,
        )..where((tbl) => tbl.eventType.equals('DEBT_CREATED'))).get();
        expect(debtEvents, hasLength(1));
        expect(debtEvents.first.targetId, 'debt-test-uuid');
      },
    );

    test(
      'recordDebtPayment atomically inserts payment, updates debt, and writes outbox events',
      () async {
        // Setup initial debt
        final debtor = DebtorEntity(
          id: 'debtor-pay-uuid',
          name: 'Ibrahima Fall',
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
        );
        final debt = DebtEntity(
          id: 'debt-pay-uuid',
          debtorId: 'debtor-pay-uuid',
          initialAmount: 8000,
          remainingAmount: 8000,
          dueDate: DateTime.utc(2026, 11, 25),
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
          status: DebtStatus.active,
        );
        await debtDataSource.recordDebtWithDebtor(
          debtor: debtor,
          debt: debt,
          isNewDebtor: true,
        );

        // Record partial payment
        final payment = DebtPaymentEntity(
          id: 'payment-pay-uuid',
          debtId: 'debt-pay-uuid',
          paymentAmount: 3000,
          paymentMethod: 'ESPECES',
          paidAt: DateTime.utc(2026, 11, 18, 15, 0),
        );
        final updatedDebt = debt.copyWith(
          remainingAmount: 5000,
          status: DebtStatus.active,
        );

        await debtDataSource.recordDebtPayment(
          payment: payment,
          updatedDebt: updatedDebt,
        );

        // Verify payment and debt status
        final payments = await debtDataSource.getPaymentsByDebt(
          'debt-pay-uuid',
        );
        expect(payments, hasLength(1));
        expect(payments.first.paymentAmount, 3000);

        final refreshedDebt = await debtDataSource.getDebtById('debt-pay-uuid');
        expect(refreshedDebt!.remainingAmount, 5000);

        // Verify outbox events
        final paymentEvents = await (db.select(
          db.syncOutbox,
        )..where((tbl) => tbl.eventType.equals('DEBT_PAYMENT_RECORDED'))).get();
        expect(paymentEvents, hasLength(1));
        expect(paymentEvents.first.targetId, 'payment-pay-uuid');

        final debtUpdateEvents = await (db.select(
          db.syncOutbox,
        )..where((tbl) => tbl.eventType.equals('DEBT_UPDATED'))).get();
        expect(debtUpdateEvents, hasLength(1));
        expect(debtUpdateEvents.first.targetId, 'debt-pay-uuid');
      },
    );
  });
}
