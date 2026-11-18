import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/domain/entities/outbox_event_entity.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';

abstract interface class SyncRepository {
  Future<Result<SyncResultEntity, Failure>> processOutboxQueue({
    int batchSize = 50,
  });

  Stream<SyncStatusSummaryEntity> watchSyncStatus();

  Future<Result<SyncStatusSummaryEntity, Failure>> getSyncStatus();

  Future<Result<void, Failure>> enqueueEvent(OutboxEventEntity event);

  Future<Result<void, Failure>> purgeSyncedEvents();

  Future<Result<void, Failure>> resetFailedEvents();
}
