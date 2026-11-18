import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import 'package:tekki/features/sync/domain/repositories/sync_repository.dart';

class GetSyncStatusUseCase {
  const GetSyncStatusUseCase({required this.repository});

  final SyncRepository repository;

  Future<Result<SyncStatusSummaryEntity, Failure>> call() {
    return repository.getSyncStatus();
  }
}
