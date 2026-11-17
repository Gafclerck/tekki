import 'package:equatable/equatable.dart';

class DailyClosureEntity extends Equatable {
  DailyClosureEntity({
    required this.id,
    required this.shopId,
    required this.closureDate,
    required DateTime cutoffTimestamp,
    required this.totalSalesAmount,
    this.totalCashDebtInflow = 0,
    this.totalCreditSalesAmount = 0,
    this.totalExpensesAmount = 0,
    this.cashCounted = 0,
    this.gpsLatitude,
    this.gpsLongitude,
    this.distanceMeters,
    this.isFlaggedLocation = false,
    this.syncStatus = 'pending',
    DateTime? lastSyncedAt,
    DateTime? createdAt,
  })  : cutoffTimestamp = cutoffTimestamp.toUtc(),
        lastSyncedAt = lastSyncedAt?.toUtc(),
        createdAt = (createdAt ?? DateTime.now()).toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError('Closure id cannot be empty');
    }
    if (shopId.trim().isEmpty) {
      throw ArgumentError('shopId cannot be empty');
    }
    if (closureDate.trim().isEmpty) {
      throw ArgumentError('closureDate cannot be empty');
    }
    if (totalSalesAmount < 0) {
      throw ArgumentError('totalSalesAmount cannot be negative');
    }
    if (totalCashDebtInflow < 0) {
      throw ArgumentError('totalCashDebtInflow cannot be negative');
    }
    if (totalCreditSalesAmount < 0) {
      throw ArgumentError('totalCreditSalesAmount cannot be negative');
    }
    if (totalExpensesAmount < 0) {
      throw ArgumentError('totalExpensesAmount cannot be negative');
    }
    if (cashCounted < 0) {
      throw ArgumentError('cashCounted cannot be negative');
    }
    if (gpsLatitude != null &&
        (gpsLatitude!.isNaN || gpsLatitude! < -90.0 || gpsLatitude! > 90.0)) {
      throw ArgumentError('gpsLatitude must be between -90 and 90');
    }
    if (gpsLongitude != null &&
        (gpsLongitude!.isNaN || gpsLongitude! < -180.0 || gpsLongitude! > 180.0)) {
      throw ArgumentError('gpsLongitude must be between -180 and 180');
    }
    if (distanceMeters != null &&
        (distanceMeters!.isNaN || distanceMeters! < 0)) {
      throw ArgumentError('distanceMeters cannot be negative');
    }
  }

  const DailyClosureEntity.raw({
    required this.id,
    required this.shopId,
    required this.closureDate,
    required this.cutoffTimestamp,
    required this.totalSalesAmount,
    this.totalCashDebtInflow = 0,
    this.totalCreditSalesAmount = 0,
    this.totalExpensesAmount = 0,
    this.cashCounted = 0,
    this.gpsLatitude,
    this.gpsLongitude,
    this.distanceMeters,
    this.isFlaggedLocation = false,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
    required this.createdAt,
  });

  final String id;
  final String shopId;
  final String closureDate;
  final DateTime cutoffTimestamp;
  final int totalSalesAmount;
  final int totalCashDebtInflow;
  final int totalCreditSalesAmount;
  final int totalExpensesAmount;
  final int cashCounted;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final double? distanceMeters;
  final bool isFlaggedLocation;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;

  DateTime get closedAt => createdAt;

  int get theoreticalCash =>
      totalSalesAmount + totalCashDebtInflow - totalExpensesAmount;

  int get difference => cashCounted - theoreticalCash;

  DailyClosureEntity copyWith({
    String? id,
    String? shopId,
    String? closureDate,
    DateTime? cutoffTimestamp,
    int? totalSalesAmount,
    int? totalCashDebtInflow,
    int? totalCreditSalesAmount,
    int? totalExpensesAmount,
    int? cashCounted,
    double? gpsLatitude,
    bool clearGpsLatitude = false,
    double? gpsLongitude,
    bool clearGpsLongitude = false,
    double? distanceMeters,
    bool clearDistanceMeters = false,
    bool? isFlaggedLocation,
    String? syncStatus,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    DateTime? createdAt,
  }) {
    return DailyClosureEntity(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      closureDate: closureDate ?? this.closureDate,
      cutoffTimestamp: cutoffTimestamp ?? this.cutoffTimestamp,
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      totalCashDebtInflow: totalCashDebtInflow ?? this.totalCashDebtInflow,
      totalCreditSalesAmount:
          totalCreditSalesAmount ?? this.totalCreditSalesAmount,
      totalExpensesAmount: totalExpensesAmount ?? this.totalExpensesAmount,
      cashCounted: cashCounted ?? this.cashCounted,
      gpsLatitude:
          clearGpsLatitude ? null : (gpsLatitude ?? this.gpsLatitude),
      gpsLongitude:
          clearGpsLongitude ? null : (gpsLongitude ?? this.gpsLongitude),
      distanceMeters:
          clearDistanceMeters ? null : (distanceMeters ?? this.distanceMeters),
      isFlaggedLocation: isFlaggedLocation ?? this.isFlaggedLocation,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: clearLastSyncedAt
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        closureDate,
        cutoffTimestamp,
        totalSalesAmount,
        totalCashDebtInflow,
        totalCreditSalesAmount,
        totalExpensesAmount,
        cashCounted,
        gpsLatitude,
        gpsLongitude,
        distanceMeters,
        isFlaggedLocation,
        syncStatus,
        lastSyncedAt,
        createdAt,
      ];
}
