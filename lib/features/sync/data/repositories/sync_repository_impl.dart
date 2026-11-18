import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/data/datasources/outbox_local_data_source.dart';
import 'package:tekki/features/sync/data/datasources/remote_sync_api_client.dart';
import 'package:tekki/features/sync/data/models/outbox_event_model.dart';
import 'package:tekki/features/sync/domain/entities/outbox_event_entity.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import 'package:tekki/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.outboxLocalDataSource,
    required this.remoteSyncApiClient,
    required this.networkInfo,
  });

  final OutboxLocalDataSource outboxLocalDataSource;
  final RemoteSyncApiClient remoteSyncApiClient;
  final NetworkInfo networkInfo;

  @override
  Future<Result<SyncResultEntity, Failure>> processOutboxQueue({
    int batchSize = 50,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Result.success(const SyncResultEntity.offline());
      }

      final pendingEvents = await outboxLocalDataSource.getPendingEvents(
        limit: batchSize,
      );
      if (pendingEvents.isEmpty) {
        return Result.success(const SyncResultEntity.empty());
      }

      final response = await remoteSyncApiClient.sendBatch(pendingEvents);

      if (response.isSuccess) {
        final processedIds = response.processedEventIds.toSet();
        final syncedEvents = pendingEvents
            .where((e) => processedIds.contains(e.clientEventId))
            .toList();

        // 1. Update associated business entities to sync_status = 'synced'
        await outboxLocalDataSource.updateTargetEntitiesSynced(syncedEvents);

        // 2. Mark outbox events as synced
        await outboxLocalDataSource.markEventsSynced(
          response.processedEventIds,
        );

        // 3. Purge synced entries from outbox table
        await outboxLocalDataSource.purgeSyncedEvents();

        // 4. Record any failed items in this batch
        for (final failedId in response.failedEventIds) {
          await outboxLocalDataSource.markEventFailed(
            failedId,
            'Server reported item processing failure',
          );
        }

        return Result.success(
          SyncResultEntity(
            processedCount: pendingEvents.length,
            successCount: response.processedEventIds.length,
            failedCount: response.failedEventIds.length,
            syncedEventIds: response.processedEventIds,
            failedEventIds: response.failedEventIds,
          ),
        );
      } else {
        // Mark all batch events as failed with the error message
        final errorMsg =
            response.errorMessage ?? 'Batch synchronization failed';
        for (final event in pendingEvents) {
          await outboxLocalDataSource.markEventFailed(
            event.clientEventId,
            errorMsg,
          );
        }

        return Result.failure(SyncFailure(message: errorMsg));
      }
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        SyncFailure(message: 'Unexpected sync queue processing error: $e'),
      );
    }
  }

  @override
  Stream<SyncStatusSummaryEntity> watchSyncStatus() {
    return outboxLocalDataSource.watchSyncStatus();
  }

  @override
  Future<Result<SyncStatusSummaryEntity, Failure>> getSyncStatus() async {
    try {
      final summary = await outboxLocalDataSource.getSyncStatus();
      return Result.success(summary);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        SyncFailure(message: 'Failed to retrieve sync status: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> enqueueEvent(OutboxEventEntity event) async {
    try {
      await outboxLocalDataSource.enqueueEvent(
        OutboxEventModel.fromEntity(event),
      );
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        SyncFailure(message: 'Failed to enqueue outbox event: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> purgeSyncedEvents() async {
    try {
      await outboxLocalDataSource.purgeSyncedEvents();
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        SyncFailure(message: 'Failed to purge synced events: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> resetFailedEvents() async {
    try {
      await outboxLocalDataSource.resetFailedEvents();
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    } catch (e) {
      return Result.failure(
        SyncFailure(message: 'Failed to reset failed events: $e'),
      );
    }
  }
}
