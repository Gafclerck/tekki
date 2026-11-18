import 'dart:async';

abstract interface class SyncDispatcher {
  Future<void> schedulePeriodicSync({int intervalMinutes = 15});

  Future<void> triggerImmediateSync();

  Future<void> cancelSync();

  bool get isScheduled;

  bool isBatteryAdequate({int thresholdPercent = 15});
}

class WorkManagerSyncDispatcher implements SyncDispatcher {
  WorkManagerSyncDispatcher({
    this.onImmediateSyncTriggered,
    this.batteryLevelOverride,
  });

  final Future<void> Function()? onImmediateSyncTriggered;
  final int? batteryLevelOverride;
  bool _isScheduled = false;

  @override
  bool get isScheduled => _isScheduled;

  @override
  bool isBatteryAdequate({int thresholdPercent = 15}) {
    final level = batteryLevelOverride ?? 100;
    return level > thresholdPercent;
  }

  @override
  Future<void> schedulePeriodicSync({int intervalMinutes = 15}) async {
    _isScheduled = true;
  }

  @override
  Future<void> triggerImmediateSync() async {
    final callback = onImmediateSyncTriggered;
    if (callback != null) {
      await callback();
    }
  }

  @override
  Future<void> cancelSync() async {
    _isScheduled = false;
  }
}
