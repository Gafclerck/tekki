import 'package:equatable/equatable.dart';

class SyncResultEntity extends Equatable {
  const SyncResultEntity({
    required this.processedCount,
    required this.successCount,
    required this.failedCount,
    required this.syncedEventIds,
    this.failedEventIds = const [],
    this.errorMessage,
    this.isOffline = false,
  });

  const SyncResultEntity.empty()
    : processedCount = 0,
      successCount = 0,
      failedCount = 0,
      syncedEventIds = const [],
      failedEventIds = const [],
      errorMessage = null,
      isOffline = false;

  const SyncResultEntity.offline()
    : processedCount = 0,
      successCount = 0,
      failedCount = 0,
      syncedEventIds = const [],
      failedEventIds = const [],
      errorMessage = 'Offline: waiting for network connectivity',
      isOffline = true;

  final int processedCount;
  final int successCount;
  final int failedCount;
  final List<String> syncedEventIds;
  final List<String> failedEventIds;
  final String? errorMessage;
  final bool isOffline;

  bool get isSuccess => failedCount == 0 && errorMessage == null;

  @override
  List<Object?> get props => [
    processedCount,
    successCount,
    failedCount,
    syncedEventIds,
    failedEventIds,
    errorMessage,
    isOffline,
  ];
}
