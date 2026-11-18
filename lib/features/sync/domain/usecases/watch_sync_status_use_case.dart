import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import 'package:tekki/features/sync/domain/repositories/sync_repository.dart';

class WatchSyncStatusUseCase {
  const WatchSyncStatusUseCase({required this.repository});

  final SyncRepository repository;

  Stream<SyncStatusSummaryEntity> call() {
    return repository.watchSyncStatus();
  }
}
