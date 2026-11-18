import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_state.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchSyncStatusUseCase mockWatchSyncStatusUseCase;
  late MockProcessOutboxQueueUseCase mockProcessOutboxQueueUseCase;
  late MockGetSyncStatusUseCase mockGetSyncStatusUseCase;
  late MockNetworkInfo mockNetworkInfo;
  late StreamController<SyncStatusSummaryEntity> statusStreamController;
  late StreamController<bool> networkStreamController;

  setUp(() {
    mockWatchSyncStatusUseCase = MockWatchSyncStatusUseCase();
    mockProcessOutboxQueueUseCase = MockProcessOutboxQueueUseCase();
    mockGetSyncStatusUseCase = MockGetSyncStatusUseCase();
    mockNetworkInfo = MockNetworkInfo();

    statusStreamController =
        StreamController<SyncStatusSummaryEntity>.broadcast();
    networkStreamController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(
      () => mockNetworkInfo.onConnectivityChanged,
    ).thenAnswer((_) => networkStreamController.stream);
    when(
      () => mockWatchSyncStatusUseCase(),
    ).thenAnswer((_) => statusStreamController.stream);
  });

  tearDown(() async {
    await statusStreamController.close();
    await networkStreamController.close();
  });

  SyncCubit buildCubit() {
    return SyncCubit(
      watchSyncStatusUseCase: mockWatchSyncStatusUseCase,
      processOutboxQueueUseCase: mockProcessOutboxQueueUseCase,
      getSyncStatusUseCase: mockGetSyncStatusUseCase,
      networkInfo: mockNetworkInfo,
    );
  }

  group('SyncCubit Unit Tests', () {
    test('Initial state is SyncState with default summary', () {
      final cubit = buildCubit();
      expect(cubit.state, const SyncState());
      cubit.close();
    });

    blocTest<SyncCubit, SyncState>(
      'Emits updated summary when watchSyncStatusUseCase emits',
      build: buildCubit,
      act: (_) {
        statusStreamController.add(
          createTestSyncStatusSummary(pendingCount: 2),
        );
      },
      expect: () => [predicate<SyncState>((s) => s.summary.pendingCount == 2)],
    );

    blocTest<SyncCubit, SyncState>(
      'Emits isOnline update when network connectivity changes',
      build: buildCubit,
      act: (_) {
        networkStreamController.add(false);
      },
      expect: () => [predicate<SyncState>((s) => s.isOnline == false)],
    );

    blocTest<SyncCubit, SyncState>(
      'syncNow emits isSyncing true then false on successful sync',
      build: () {
        when(
          () =>
              mockProcessOutboxQueueUseCase(batchSize: any(named: 'batchSize')),
        ).thenAnswer(
          (_) async => Result.success(
            const SyncResultEntity(
              processedCount: 3,
              successCount: 3,
              failedCount: 0,
              syncedEventIds: ['1', '2', '3'],
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.syncNow(),
      expect: () => [
        predicate<SyncState>(
          (s) => s.isSyncing == true && s.errorMessage == null,
        ),
        predicate<SyncState>(
          (s) => s.isSyncing == false && s.errorMessage == null,
        ),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'syncNow emits errorMessage on sync failure',
      build: () {
        when(
          () =>
              mockProcessOutboxQueueUseCase(batchSize: any(named: 'batchSize')),
        ).thenAnswer(
          (_) async =>
              Result.failure(const SyncFailure(message: 'Server unreachable')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.syncNow(),
      expect: () => [
        predicate<SyncState>((s) => s.isSyncing == true),
        predicate<SyncState>(
          (s) => s.isSyncing == false && s.errorMessage == 'Server unreachable',
        ),
      ],
    );
  });
}
