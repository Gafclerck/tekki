import 'package:equatable/equatable.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';

class SyncState extends Equatable {
  const SyncState({
    this.summary = const SyncStatusSummaryEntity.initial(),
    this.isSyncing = false,
    this.errorMessage,
    this.lastSyncTriggeredAt,
  });

  final SyncStatusSummaryEntity summary;
  final bool isSyncing;
  final String? errorMessage;
  final DateTime? lastSyncTriggeredAt;

  int get pendingCount => summary.pendingCount;
  int get failedCount => summary.failedCount;
  int get syncedCount => summary.syncedCount;
  DateTime? get lastSyncedAt => summary.lastSyncedAt;
  bool get isOnline => summary.isOnline;
  bool get isFullySynced => summary.isFullySynced;

  SyncState copyWith({
    SyncStatusSummaryEntity? summary,
    bool? isSyncing,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastSyncTriggeredAt,
  }) {
    return SyncState(
      summary: summary ?? this.summary,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncTriggeredAt: lastSyncTriggeredAt ?? this.lastSyncTriggeredAt,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    isSyncing,
    errorMessage,
    lastSyncTriggeredAt,
  ];
}
