import 'dart:async';
import 'dart:math';

import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/features/sync/data/datasources/workmanager_dispatcher.dart';
import 'package:tekki/features/sync/domain/entities/sync_result_entity.dart';
import 'package:tekki/features/sync/domain/repositories/sync_repository.dart';

class SyncOrchestrator {
  SyncOrchestrator({
    required this.syncRepository,
    required this.networkInfo,
    required this.syncDispatcher,
    int initialBackoffSeconds = AppConstants.syncInitialBackoffSeconds,
    int maxBackoffMinutes = AppConstants.syncMaxBackoffMinutes,
  }) : _initialBackoff = Duration(seconds: initialBackoffSeconds),
       _maxBackoff = Duration(minutes: maxBackoffMinutes);

  final SyncRepository syncRepository;
  final NetworkInfo networkInfo;
  final SyncDispatcher syncDispatcher;
  final Duration _initialBackoff;
  final Duration _maxBackoff;

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _backoffTimer;
  int _consecutiveFailures = 0;
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;
  int get consecutiveFailures => _consecutiveFailures;

  void start() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        // Network restored: reset backoff and attempt immediate sync
        _consecutiveFailures = 0;
        _cancelBackoffTimer();
        syncNow();
      }
    });

    // Initial check
    networkInfo.isConnected.then((connected) {
      if (connected) {
        syncNow();
      }
    });

    syncDispatcher.schedulePeriodicSync(
      intervalMinutes: AppConstants.defaultSyncIntervalMinutes,
    );
  }

  Future<SyncResultEntity?> syncNow({int batchSize = 50}) async {
    if (_isSyncing) return null;

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const SyncResultEntity.offline();
    }

    if (!syncDispatcher.isBatteryAdequate(thresholdPercent: 15)) {
      return const SyncResultEntity(
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        syncedEventIds: [],
        errorMessage: 'Sync suspended: battery level below 15%',
      );
    }

    _isSyncing = true;
    try {
      final result = await syncRepository.processOutboxQueue(
        batchSize: batchSize,
      );

      return result.fold(
        onSuccess: (syncResult) {
          if (syncResult.isSuccess) {
            _consecutiveFailures = 0;
            _cancelBackoffTimer();
          } else {
            _scheduleSilentBackoff();
          }
          return syncResult;
        },
        onError: (failure) {
          _scheduleSilentBackoff();
          return SyncResultEntity(
            processedCount: 0,
            successCount: 0,
            failedCount: 0,
            syncedEventIds: const [],
            errorMessage: failure.message,
          );
        },
      );
    } finally {
      _isSyncing = false;
    }
  }

  void _scheduleSilentBackoff() {
    _consecutiveFailures++;
    _cancelBackoffTimer();

    // Exponential backoff: base * (2 ^ failures) with jitter, capped at maxBackoff
    final factor = pow(2, min(_consecutiveFailures - 1, 8)).toInt();
    final delaySeconds = min(
      _initialBackoff.inSeconds * factor,
      _maxBackoff.inSeconds,
    );
    final jitterMs = Random().nextInt(1000);
    final totalDelay = Duration(seconds: delaySeconds, milliseconds: jitterMs);

    _backoffTimer = Timer(totalDelay, () {
      syncNow();
    });
  }

  void _cancelBackoffTimer() {
    _backoffTimer?.cancel();
    _backoffTimer = null;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _cancelBackoffTimer();
  }
}
