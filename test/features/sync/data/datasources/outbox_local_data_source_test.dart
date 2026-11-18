import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/data/models/debt_model.dart';
import 'package:tekki/features/karne_bor/data/models/debtor_model.dart';
import 'package:tekki/features/sales_and_cash/data/models/sale_model.dart';
import 'package:tekki/features/sync/data/datasources/outbox_local_data_source.dart';
import 'package:tekki/features/sync/data/models/outbox_event_model.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  late AppDatabase db;
  late OutboxLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = OutboxLocalDataSourceImpl(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('OutboxLocalDataSource Unit Tests', () {
    test(
      'enqueueEvent and getPendingEvents retrieves ordered pending events',
      () async {
        final event1 = OutboxEventModel(
          clientEventId: 'evt-1',
          eventType: 'SALE_CREATED',
          targetTable: 'sales',
          targetId: 'sale-1',
          payloadJson: '{"amount": 5000}',
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
        );
        final event2 = OutboxEventModel(
          clientEventId: 'evt-2',
          eventType: 'SALE_CREATED',
          targetTable: 'sales',
          targetId: 'sale-2',
          payloadJson: '{"amount": 3000}',
          createdAt: DateTime.utc(2026, 11, 18, 10, 5),
        );

        await dataSource.enqueueEvent(event1);
        await dataSource.enqueueEvent(event2);

        final pending = await dataSource.getPendingEvents(limit: 10);
        expect(pending, hasLength(2));
        expect(pending[0].clientEventId, 'evt-1');
        expect(pending[1].clientEventId, 'evt-2');
      },
    );

    test(
      'getPendingEvents respects limit and rejects non-positive limit',
      () async {
        for (var i = 1; i <= 5; i++) {
          await dataSource.enqueueEvent(
            OutboxEventModel(
              clientEventId: 'evt-$i',
              eventType: 'SALE_CREATED',
              targetTable: 'sales',
              targetId: 'sale-$i',
              payloadJson: '{"amount": $i}',
              createdAt: DateTime.utc(2026, 11, 18, 10, i),
            ),
          );
        }

        final limited = await dataSource.getPendingEvents(limit: 3);
        expect(limited, hasLength(3));

        expect(
          () => dataSource.getPendingEvents(limit: 0),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('markEventsSynced transitions status to SYNCED', () async {
      await dataSource.enqueueEvent(
        OutboxEventModel(
          clientEventId: 'sync-target-1',
          eventType: 'SALE_CREATED',
          targetTable: 'sales',
          targetId: 'sale-1',
          payloadJson: '{}',
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
        ),
      );

      await dataSource.markEventsSynced(['sync-target-1']);

      final pending = await dataSource.getPendingEvents(limit: 10);
      expect(pending, isEmpty);

      final status = await dataSource.getSyncStatus();
      expect(status.syncedCount, 1);
      expect(status.pendingCount, 0);
      expect(status.lastSyncedAt, isNotNull);
    });

    test(
      'markEventFailed increments retryCount and records errorMessage',
      () async {
        await dataSource.enqueueEvent(
          OutboxEventModel(
            clientEventId: 'fail-target-1',
            eventType: 'SALE_CREATED',
            targetTable: 'sales',
            targetId: 'sale-1',
            payloadJson: '{}',
            createdAt: DateTime.utc(2026, 11, 18, 10, 0),
          ),
        );

        await dataSource.markEventFailed(
          'fail-target-1',
          'HTTP 500 Internal Error',
        );

        final status = await dataSource.getSyncStatus();
        expect(status.failedCount, 1);
        expect(status.pendingCount, 0);

        // Second failure increments retry count
        await dataSource.markEventFailed('fail-target-1', 'Timeout');
        final rows = await db.select(db.syncOutbox).get();
        expect(rows.first.retryCount, 2);
        expect(rows.first.errorMessage, 'Timeout');
      },
    );

    test('resetFailedEvents moves FAILED events back to PENDING', () async {
      await dataSource.enqueueEvent(
        OutboxEventModel(
          clientEventId: 'retry-evt-1',
          eventType: 'SALE_CREATED',
          targetTable: 'sales',
          targetId: 'sale-1',
          payloadJson: '{}',
          status: 'FAILED',
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
        ),
      );

      await dataSource.resetFailedEvents();

      final pending = await dataSource.getPendingEvents(limit: 10);
      expect(pending, hasLength(1));
      expect(pending.first.clientEventId, 'retry-evt-1');
    });

    test(
      'purgeSyncedEvents removes only SYNCED records and returns count',
      () async {
        await dataSource.enqueueEvent(
          OutboxEventModel(
            clientEventId: 'evt-synced-1',
            eventType: 'SALE_CREATED',
            targetTable: 'sales',
            targetId: 'sale-1',
            payloadJson: '{}',
            status: 'SYNCED',
            createdAt: DateTime.utc(2026, 11, 18, 10, 0),
          ),
        );
        await dataSource.enqueueEvent(
          OutboxEventModel(
            clientEventId: 'evt-pending-1',
            eventType: 'SALE_CREATED',
            targetTable: 'sales',
            targetId: 'sale-2',
            payloadJson: '{}',
            status: 'PENDING',
            createdAt: DateTime.utc(2026, 11, 18, 10, 5),
          ),
        );

        final purged = await dataSource.purgeSyncedEvents();
        expect(purged, 1);

        final remaining = await db.select(db.syncOutbox).get();
        expect(remaining, hasLength(1));
        expect(remaining.first.clientEventId, 'evt-pending-1');
      },
    );

    test(
      'updateTargetEntitiesSynced sets syncStatus = synced on sales and debts',
      () async {
        // Seed a sale and a debtor/debt
        await db
            .into(db.sales)
            .insert(
              SaleModel.fromEntity(
                createTestSale(id: 'target-sale-1', syncStatus: 'pending'),
              ).toCompanion(),
            );
        await db
            .into(db.debtors)
            .insert(
              DebtorModel.fromEntity(
                createTestDebtor(id: 'target-debtor-1'),
              ).toCompanion(),
            );
        await db
            .into(db.debts)
            .insert(
              DebtModel.fromEntity(
                createTestDebt(
                  id: 'target-debt-1',
                  debtorId: 'target-debtor-1',
                ),
              ).toCompanion(),
            );

        final events = [
          OutboxEventModel(
            clientEventId: 'evt-s1',
            eventType: 'SALE_CREATED',
            targetTable: 'sales',
            targetId: 'target-sale-1',
            payloadJson: '{}',
            createdAt: DateTime.utc(2026, 11, 18, 10, 0),
          ),
          OutboxEventModel(
            clientEventId: 'evt-d1',
            eventType: 'DEBT_CREATED',
            targetTable: 'debts',
            targetId: 'target-debt-1',
            payloadJson: '{}',
            createdAt: DateTime.utc(2026, 11, 18, 10, 0),
          ),
        ];

        await dataSource.updateTargetEntitiesSynced(events);

        final updatedSale = await (db.select(
          db.sales,
        )..where((tbl) => tbl.id.equals('target-sale-1'))).getSingle();
        expect(updatedSale.syncStatus, 'synced');
        expect(updatedSale.lastSyncedAt, isNotNull);

        final updatedDebt = await (db.select(
          db.debts,
        )..where((tbl) => tbl.id.equals('target-debt-1'))).getSingle();
        expect(updatedDebt.syncStatus, 'synced');
        expect(updatedDebt.lastSyncedAt, isNotNull);
      },
    );

    test('watchSyncStatus emits reactive summary stream', () async {
      final expectation = expectLater(
        dataSource.watchSyncStatus(),
        emits(
          predicate<SyncStatusSummaryEntity>(
            (summary) => summary.pendingCount == 1,
          ),
        ),
      );

      await dataSource.enqueueEvent(
        OutboxEventModel(
          clientEventId: 'stream-evt-1',
          eventType: 'SALE_CREATED',
          targetTable: 'sales',
          targetId: 'sale-1',
          payloadJson: '{}',
          createdAt: DateTime.utc(2026, 11, 18, 10, 0),
        ),
      );

      await expectation;
    });
  });
}
