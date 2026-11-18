import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sync/data/models/outbox_event_model.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';

abstract interface class OutboxLocalDataSource {
  Future<void> enqueueEvent(OutboxEventModel event);

  Future<List<OutboxEventModel>> getPendingEvents({int limit = 50});

  Future<void> markEventsSynced(List<String> clientEventIds);

  Future<void> markEventFailed(String clientEventId, String errorMessage);

  Future<void> updateTargetEntitiesSynced(List<OutboxEventModel> events);

  Future<int> purgeSyncedEvents();

  Future<void> resetFailedEvents();

  Stream<SyncStatusSummaryEntity> watchSyncStatus();

  Future<SyncStatusSummaryEntity> getSyncStatus();
}

class OutboxLocalDataSourceImpl implements OutboxLocalDataSource {
  OutboxLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<void> enqueueEvent(OutboxEventModel event) async {
    try {
      await database.into(database.syncOutbox).insert(event.toCompanion());
    } catch (e) {
      throw DatabaseException('Failed to enqueue outbox event: $e');
    }
  }

  @override
  Future<List<OutboxEventModel>> getPendingEvents({int limit = 50}) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final query = database.select(database.syncOutbox)
        ..where((tbl) => tbl.status.equals('PENDING'))
        ..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc),
        ])
        ..limit(limit);

      final rows = await query.get();
      return rows.map(OutboxEventModel.fromDrift).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to fetch pending outbox events: $e');
    }
  }

  @override
  Future<void> markEventsSynced(List<String> clientEventIds) async {
    if (clientEventIds.isEmpty) return;
    try {
      final nowUtcIso = DateTime.now().toUtc().toIso8601String();
      await (database.update(
        database.syncOutbox,
      )..where((tbl) => tbl.clientEventId.isIn(clientEventIds))).write(
        SyncOutboxCompanion(
          status: const Value('SYNCED'),
          lastAttemptAt: Value(nowUtcIso),
          errorMessage: const Value(null),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to mark events as synced: $e');
    }
  }

  @override
  Future<void> markEventFailed(
    String clientEventId,
    String errorMessage,
  ) async {
    try {
      final nowUtcIso = DateTime.now().toUtc().toIso8601String();
      final row =
          await (database.select(database.syncOutbox)
                ..where((tbl) => tbl.clientEventId.equals(clientEventId)))
              .getSingleOrNull();

      final currentRetry = row?.retryCount ?? 0;

      await (database.update(
        database.syncOutbox,
      )..where((tbl) => tbl.clientEventId.equals(clientEventId))).write(
        SyncOutboxCompanion(
          retryCount: Value(currentRetry + 1),
          status: const Value('FAILED'),
          lastAttemptAt: Value(nowUtcIso),
          errorMessage: Value(errorMessage),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to mark event as failed: $e');
    }
  }

  @override
  Future<void> updateTargetEntitiesSynced(List<OutboxEventModel> events) async {
    if (events.isEmpty) return;
    try {
      final nowUtcIso = DateTime.now().toUtc().toIso8601String();
      await database.transaction(() async {
        for (final event in events) {
          switch (event.targetTable) {
            case 'sales':
              await (database.update(
                database.sales,
              )..where((tbl) => tbl.id.equals(event.targetId))).write(
                SalesCompanion(
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(nowUtcIso),
                ),
              );
              break;
            case 'daily_closures':
              await (database.update(
                database.dailyClosures,
              )..where((tbl) => tbl.id.equals(event.targetId))).write(
                DailyClosuresCompanion(
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(nowUtcIso),
                ),
              );
              break;
            case 'debts':
              await (database.update(
                database.debts,
              )..where((tbl) => tbl.id.equals(event.targetId))).write(
                DebtsCompanion(
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(nowUtcIso),
                ),
              );
              break;
            case 'debt_payments':
              await (database.update(
                database.debtPayments,
              )..where((tbl) => tbl.id.equals(event.targetId))).write(
                DebtPaymentsCompanion(
                  syncStatus: const Value('synced'),
                  lastSyncedAt: Value(nowUtcIso),
                ),
              );
              break;
            default:
              break;
          }
        }
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to update target entities sync status: $e',
      );
    }
  }

  @override
  Future<int> purgeSyncedEvents() async {
    try {
      final deletedCount = await (database.delete(
        database.syncOutbox,
      )..where((tbl) => tbl.status.equals('SYNCED'))).go();
      return deletedCount;
    } catch (e) {
      throw DatabaseException('Failed to purge synced events: $e');
    }
  }

  @override
  Future<void> resetFailedEvents() async {
    try {
      await (database.update(
        database.syncOutbox,
      )..where((tbl) => tbl.status.equals('FAILED'))).write(
        const SyncOutboxCompanion(
          status: Value('PENDING'),
          errorMessage: Value(null),
        ),
      );
    } catch (e) {
      throw DatabaseException('Failed to reset failed events: $e');
    }
  }

  @override
  Stream<SyncStatusSummaryEntity> watchSyncStatus() {
    try {
      return database.select(database.syncOutbox).watch().map((rows) {
        int pending = 0;
        int failed = 0;
        int synced = 0;
        DateTime? latestSync;

        for (final row in rows) {
          switch (row.status) {
            case 'PENDING':
              pending++;
              break;
            case 'FAILED':
              failed++;
              break;
            case 'SYNCED':
              synced++;
              if (row.lastAttemptAt != null) {
                final d = DateTime.tryParse(row.lastAttemptAt!);
                if (d != null &&
                    (latestSync == null || d.isAfter(latestSync))) {
                  latestSync = d;
                }
              }
              break;
          }
        }

        return SyncStatusSummaryEntity(
          pendingCount: pending,
          failedCount: failed,
          syncedCount: synced,
          lastSyncedAt: latestSync,
          isSyncing: false,
        );
      });
    } catch (e) {
      throw DatabaseException('Failed to watch sync status: $e');
    }
  }

  @override
  Future<SyncStatusSummaryEntity> getSyncStatus() async {
    try {
      final rows = await database.select(database.syncOutbox).get();
      int pending = 0;
      int failed = 0;
      int synced = 0;
      DateTime? latestSync;

      for (final row in rows) {
        switch (row.status) {
          case 'PENDING':
            pending++;
            break;
          case 'FAILED':
            failed++;
            break;
          case 'SYNCED':
            synced++;
            if (row.lastAttemptAt != null) {
              final d = DateTime.tryParse(row.lastAttemptAt!);
              if (d != null && (latestSync == null || d.isAfter(latestSync))) {
                latestSync = d;
              }
            }
            break;
        }
      }

      return SyncStatusSummaryEntity(
        pendingCount: pending,
        failedCount: failed,
        syncedCount: synced,
        lastSyncedAt: latestSync,
        isSyncing: false,
      );
    } catch (e) {
      throw DatabaseException('Failed to get sync status: $e');
    }
  }
}
