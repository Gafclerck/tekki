import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/repositories/sync_repository.dart';

class ProcessOutboxQueueUseCase {
  const ProcessOutboxQueueUseCase({required this.repository});

  final SyncRepository repository;

  Future<Result<SyncResultEntity, Failure>> call({int batchSize = 50}) {
    return repository.processOutboxQueue(batchSize: batchSize);
  }
}
