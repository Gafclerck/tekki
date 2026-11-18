import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/usecases/get_sync_status_use_case.dart';
import 'package:tekki/features/sync/domain/usecases/process_outbox_queue_use_case.dart';
import 'package:tekki/features/sync/domain/usecases/watch_sync_status_use_case.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockSyncRepository mockRepository;
  late ProcessOutboxQueueUseCase processQueueUseCase;
  late WatchSyncStatusUseCase watchStatusUseCase;
  late GetSyncStatusUseCase getStatusUseCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    processQueueUseCase = ProcessOutboxQueueUseCase(repository: mockRepository);
    watchStatusUseCase = WatchSyncStatusUseCase(repository: mockRepository);
    getStatusUseCase = GetSyncStatusUseCase(repository: mockRepository);
  });

  group('Sync Use Cases Unit Tests', () {
    test(
      'ProcessOutboxQueueUseCase delegates to repository with batchSize',
      () async {
        const syncResult = SyncResultEntity(
          processedCount: 1,
          successCount: 1,
          failedCount: 0,
          syncedEventIds: ['evt-1'],
        );
        when(
          () => mockRepository.processOutboxQueue(batchSize: 25),
        ).thenAnswer((_) async => Result.success(syncResult));

        final result = await processQueueUseCase(batchSize: 25);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (data) => expect(data.processedCount, 1),
          onError: (_) => fail('Should succeed'),
        );
        verify(
          () => mockRepository.processOutboxQueue(batchSize: 25),
        ).called(1);
      },
    );

    test('WatchSyncStatusUseCase returns stream from repository', () {
      final summary = createTestSyncStatusSummary(pendingCount: 2);
      when(
        () => mockRepository.watchSyncStatus(),
      ).thenAnswer((_) => Stream.value(summary));

      final stream = watchStatusUseCase();

      expect(stream, emits(summary));
      verify(() => mockRepository.watchSyncStatus()).called(1);
    });

    test('GetSyncStatusUseCase returns summary from repository', () async {
      final summary = createTestSyncStatusSummary(pendingCount: 4);
      when(
        () => mockRepository.getSyncStatus(),
      ).thenAnswer((_) async => Result.success(summary));

      final result = await getStatusUseCase();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data.pendingCount, 4),
        onError: (_) => fail('Should succeed'),
      );
      verify(() => mockRepository.getSyncStatus()).called(1);
    });
  });
}
