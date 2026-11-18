import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/features/sync/data/datasources/remote_sync_api_client.dart';
import 'package:tekki/features/sync/data/models/outbox_event_model.dart';
import 'package:tekki/features/sync/data/repositories/sync_repository_impl.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockOutboxLocalDataSource mockOutbox;
  late MockRemoteSyncApiClient mockApiClient;
  late MockNetworkInfo mockNetworkInfo;
  late SyncRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeOutboxEventEntity());
  });

  setUp(() {
    mockOutbox = MockOutboxLocalDataSource();
    mockApiClient = MockRemoteSyncApiClient();
    mockNetworkInfo = MockNetworkInfo();
    repository = SyncRepositoryImpl(
      outboxLocalDataSource: mockOutbox,
      remoteSyncApiClient: mockApiClient,
      networkInfo: mockNetworkInfo,
    );
  });

  group('SyncRepositoryImpl Unit Tests', () {
    test(
      'Offline mode returns SyncResultEntity.offline() without calling API',
      () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.processOutboxQueue();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (syncResult) {
            expect(syncResult.isOffline, isTrue);
            expect(syncResult.processedCount, 0);
          },
          onError: (_) => fail('Should succeed with offline result'),
        );
        verifyZeroInteractions(mockApiClient);
      },
    );

    test('Empty queue returns SyncResultEntity.empty()', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockOutbox.getPendingEvents(limit: any(named: 'limit')),
      ).thenAnswer((_) async => []);

      final result = await repository.processOutboxQueue();

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (syncResult) {
          expect(syncResult.processedCount, 0);
          expect(syncResult.isSuccess, isTrue);
        },
        onError: (_) => fail('Should succeed with empty result'),
      );
      verifyZeroInteractions(mockApiClient);
    });

    test(
      'Successful sync marks events synced, updates entities and purges outbox',
      () async {
        final event1 = OutboxEventModel.fromEntity(
          createTestOutboxEvent(clientEventId: 'evt-1'),
        );
        final event2 = OutboxEventModel.fromEntity(
          createTestOutboxEvent(clientEventId: 'evt-2'),
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockOutbox.getPendingEvents(limit: any(named: 'limit')),
        ).thenAnswer((_) async => [event1, event2]);
        when(() => mockApiClient.sendBatch(any())).thenAnswer(
          (_) async => const RemoteSyncResponse.success(
            processedEventIds: ['evt-1', 'evt-2'],
          ),
        );
        when(
          () => mockOutbox.updateTargetEntitiesSynced(any()),
        ).thenAnswer((_) async {});
        when(() => mockOutbox.markEventsSynced(any())).thenAnswer((_) async {});
        when(() => mockOutbox.purgeSyncedEvents()).thenAnswer((_) async => 2);

        final result = await repository.processOutboxQueue();

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (syncResult) {
            expect(syncResult.processedCount, 2);
            expect(syncResult.successCount, 2);
            expect(syncResult.failedCount, 0);
            expect(syncResult.syncedEventIds, ['evt-1', 'evt-2']);
          },
          onError: (_) => fail('Should succeed'),
        );

        verify(() => mockOutbox.updateTargetEntitiesSynced(any())).called(1);
        verify(() => mockOutbox.markEventsSynced(['evt-1', 'evt-2'])).called(1);
        verify(() => mockOutbox.purgeSyncedEvents()).called(1);
      },
    );

    test(
      'Failed server response marks events failed and returns SyncFailure',
      () async {
        final event = OutboxEventModel.fromEntity(
          createTestOutboxEvent(clientEventId: 'evt-f1'),
        );

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockOutbox.getPendingEvents(limit: any(named: 'limit')),
        ).thenAnswer((_) async => [event]);
        when(() => mockApiClient.sendBatch(any())).thenAnswer(
          (_) async => const RemoteSyncResponse.failure(
            errorMessage: '503 Service Unavailable',
          ),
        );
        when(
          () => mockOutbox.markEventFailed(any(), any()),
        ).thenAnswer((_) async {});

        final result = await repository.processOutboxQueue();

        expect(result.isError, isTrue);
        result.fold(
          onSuccess: (_) => fail('Should return failure'),
          onError: (failure) {
            expect(failure, isA<SyncFailure>());
            expect(failure.message, contains('503 Service Unavailable'));
          },
        );

        verify(() => mockOutbox.markEventFailed('evt-f1', any())).called(1);
      },
    );

    test('purgeSyncedEvents delegates to datasource', () async {
      when(() => mockOutbox.purgeSyncedEvents()).thenAnswer((_) async => 5);

      final result = await repository.purgeSyncedEvents();

      expect(result.isSuccess, isTrue);
      verify(() => mockOutbox.purgeSyncedEvents()).called(1);
    });

    test('watchSyncStatus forwards stream from datasource', () {
      final summary = createTestSyncStatusSummary(pendingCount: 3);
      when(
        () => mockOutbox.watchSyncStatus(),
      ).thenAnswer((_) => Stream.value(summary));

      final stream = repository.watchSyncStatus();

      expect(stream, emits(summary));
    });
  });
}
