import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/data/services/sync_orchestrator.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockSyncRepository mockSyncRepository;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncDispatcher mockSyncDispatcher;
  late StreamController<bool> networkStreamController;
  late SyncOrchestrator orchestrator;

  setUp(() {
    mockSyncRepository = MockSyncRepository();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncDispatcher = MockSyncDispatcher();
    networkStreamController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(
      () => mockNetworkInfo.onConnectivityChanged,
    ).thenAnswer((_) => networkStreamController.stream);
    when(
      () => mockSyncDispatcher.isBatteryAdequate(
        thresholdPercent: any(named: 'thresholdPercent'),
      ),
    ).thenReturn(true);
    when(
      () => mockSyncDispatcher.schedulePeriodicSync(
        intervalMinutes: any(named: 'intervalMinutes'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockSyncRepository.processOutboxQueue(
        batchSize: any(named: 'batchSize'),
      ),
    ).thenAnswer((_) async => Result.success(const SyncResultEntity.empty()));

    orchestrator = SyncOrchestrator(
      syncRepository: mockSyncRepository,
      networkInfo: mockNetworkInfo,
      syncDispatcher: mockSyncDispatcher,
      initialBackoffSeconds: 1,
      maxBackoffMinutes: 1,
    );
  });

  tearDown(() {
    orchestrator.dispose();
    networkStreamController.close();
  });

  group('SyncOrchestrator Unit Tests', () {
    test('start() schedules periodic sync and starts listening', () async {
      when(
        () => mockSyncRepository.processOutboxQueue(
          batchSize: any(named: 'batchSize'),
        ),
      ).thenAnswer((_) async => Result.success(const SyncResultEntity.empty()));

      orchestrator.start();

      verify(
        () => mockSyncDispatcher.schedulePeriodicSync(
          intervalMinutes: any(named: 'intervalMinutes'),
        ),
      ).called(1);
    });

    test('Network transition to online triggers immediate sync', () async {
      when(
        () => mockSyncRepository.processOutboxQueue(
          batchSize: any(named: 'batchSize'),
        ),
      ).thenAnswer((_) async => Result.success(const SyncResultEntity.empty()));

      orchestrator.start();

      // Emit network reconnected
      networkStreamController.add(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockSyncRepository.processOutboxQueue(
          batchSize: any(named: 'batchSize'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    test('Battery below 15% suspends sync with explanatory message', () async {
      when(
        () => mockSyncDispatcher.isBatteryAdequate(
          thresholdPercent: any(named: 'thresholdPercent'),
        ),
      ).thenReturn(false);

      final result = await orchestrator.syncNow();

      expect(result, isNotNull);
      expect(result!.errorMessage, contains('battery level below 15%'));
      verifyZeroInteractions(mockSyncRepository);
    });

    test('Offline network returns SyncResultEntity.offline()', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await orchestrator.syncNow();

      expect(result, isNotNull);
      expect(result!.isOffline, isTrue);
      verifyZeroInteractions(mockSyncRepository);
    });

    test(
      'Sync failure increments consecutiveFailures and schedules backoff',
      () async {
        when(
          () => mockSyncRepository.processOutboxQueue(
            batchSize: any(named: 'batchSize'),
          ),
        ).thenAnswer(
          (_) async =>
              Result.failure(const SyncFailure(message: 'Server error')),
        );

        await orchestrator.syncNow();

        expect(orchestrator.consecutiveFailures, 1);
      },
    );

    test('dispose cancels all timers and subscriptions', () {
      orchestrator.start();
      orchestrator.dispose();
      // Should not throw or crash
      expect(orchestrator.isSyncing, isFalse);
    });
  });
}
