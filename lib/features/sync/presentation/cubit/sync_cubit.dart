import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/features/sync/domain/usecases/get_sync_status_use_case.dart';
import 'package:tekki/features/sync/domain/usecases/process_outbox_queue_use_case.dart';
import 'package:tekki/features/sync/domain/usecases/watch_sync_status_use_case.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required this.watchSyncStatusUseCase,
    required this.processOutboxQueueUseCase,
    required this.getSyncStatusUseCase,
    required this.networkInfo,
  }) : super(const SyncState()) {
    _init();
  }

  final WatchSyncStatusUseCase watchSyncStatusUseCase;
  final ProcessOutboxQueueUseCase processOutboxQueueUseCase;
  final GetSyncStatusUseCase getSyncStatusUseCase;
  final NetworkInfo networkInfo;

  StreamSubscription<dynamic>? _statusSubscription;
  StreamSubscription<bool>? _networkSubscription;

  void _init() {
    // Initial check of network
    networkInfo.isConnected.then((connected) {
      if (!isClosed && state.summary.isOnline != connected) {
        emit(
          state.copyWith(summary: state.summary.copyWith(isOnline: connected)),
        );
      }
    });

    _networkSubscription = networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      if (!isClosed && state.summary.isOnline != connected) {
        emit(
          state.copyWith(summary: state.summary.copyWith(isOnline: connected)),
        );
      }
    });

    _statusSubscription = watchSyncStatusUseCase().listen((summary) {
      if (!isClosed) {
        emit(
          state.copyWith(
            summary: summary.copyWith(isOnline: state.summary.isOnline),
          ),
        );
      }
    });
  }

  Future<void> syncNow({int batchSize = 50}) async {
    if (state.isSyncing) return;

    emit(
      state.copyWith(
        isSyncing: true,
        clearError: true,
        lastSyncTriggeredAt: DateTime.now().toUtc(),
      ),
    );

    final result = await processOutboxQueueUseCase(batchSize: batchSize);

    if (!isClosed) {
      result.fold(
        onSuccess: (syncResult) {
          emit(
            state.copyWith(
              isSyncing: false,
              errorMessage: syncResult.errorMessage,
            ),
          );
        },
        onError: (failure) {
          emit(state.copyWith(isSyncing: false, errorMessage: failure.message));
        },
      );
    }
  }

  Future<void> refreshStatus() async {
    final result = await getSyncStatusUseCase();
    if (!isClosed) {
      result.fold(
        onSuccess: (summary) {
          emit(
            state.copyWith(
              summary: summary.copyWith(isOnline: state.summary.isOnline),
            ),
          );
        },
        onError: (_) {},
      );
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _networkSubscription?.cancel();
    return super.close();
  }
}
