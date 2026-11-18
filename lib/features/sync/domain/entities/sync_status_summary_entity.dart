import 'package:equatable/equatable.dart';

class SyncStatusSummaryEntity extends Equatable {
  const SyncStatusSummaryEntity({
    required this.pendingCount,
    required this.failedCount,
    required this.syncedCount,
    this.lastSyncedAt,
    this.isSyncing = false,
    this.isOnline = true,
  });

  const SyncStatusSummaryEntity.initial()
    : pendingCount = 0,
      failedCount = 0,
      syncedCount = 0,
      lastSyncedAt = null,
      isSyncing = false,
      isOnline = true;

  final int pendingCount;
  final int failedCount;
  final int syncedCount;
  final DateTime? lastSyncedAt;
  final bool isSyncing;
  final bool isOnline;

  bool get hasPending => pendingCount > 0;
  bool get hasFailed => failedCount > 0;
  bool get isFullySynced => pendingCount == 0 && failedCount == 0;

  SyncStatusSummaryEntity copyWith({
    int? pendingCount,
    int? failedCount,
    int? syncedCount,
    DateTime? lastSyncedAt,
    bool? isSyncing,
    bool? isOnline,
  }) {
    return SyncStatusSummaryEntity(
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      syncedCount: syncedCount ?? this.syncedCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
    pendingCount,
    failedCount,
    syncedCount,
    lastSyncedAt,
    isSyncing,
    isOnline,
  ];
}
