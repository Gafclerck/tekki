import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

class DailyClosureModel extends DailyClosureEntity {
  DailyClosureModel({
    required super.id,
    required super.shopId,
    required super.closureDate,
    required super.cutoffTimestamp,
    required super.totalSalesAmount,
    super.totalCashDebtInflow = 0,
    super.totalCreditSalesAmount = 0,
    super.totalExpensesAmount = 0,
    super.cashCounted = 0,
    super.gpsLatitude,
    super.gpsLongitude,
    super.distanceMeters,
    super.isFlaggedLocation = false,
    super.syncStatus = 'pending',
    super.lastSyncedAt,
    super.createdAt,
  });

  factory DailyClosureModel.fromEntity(DailyClosureEntity entity) {
    return DailyClosureModel(
      id: entity.id,
      shopId: entity.shopId,
      closureDate: entity.closureDate,
      cutoffTimestamp: entity.cutoffTimestamp,
      totalSalesAmount: entity.totalSalesAmount,
      totalCashDebtInflow: entity.totalCashDebtInflow,
      totalCreditSalesAmount: entity.totalCreditSalesAmount,
      totalExpensesAmount: entity.totalExpensesAmount,
      cashCounted: entity.cashCounted,
      gpsLatitude: entity.gpsLatitude,
      gpsLongitude: entity.gpsLongitude,
      distanceMeters: entity.distanceMeters,
      isFlaggedLocation: entity.isFlaggedLocation,
      syncStatus: entity.syncStatus,
      lastSyncedAt: entity.lastSyncedAt,
      createdAt: entity.createdAt,
    );
  }

  factory DailyClosureModel.fromDrift(DailyClosure row) {
    return DailyClosureModel(
      id: row.id,
      shopId: row.shopId,
      closureDate: row.closureDate,
      cutoffTimestamp: DateTime.parse(row.cutoffTimestamp),
      totalSalesAmount: row.totalSalesAmount,
      totalCashDebtInflow: row.totalCashDebtInflow,
      totalCreditSalesAmount: row.totalCreditSalesAmount,
      totalExpensesAmount: row.totalExpensesAmount,
      cashCounted: row.cashCounted,
      gpsLatitude: row.gpsLatitude,
      gpsLongitude: row.gpsLongitude,
      distanceMeters: row.distanceMeters,
      isFlaggedLocation: row.isFlaggedLocation,
      syncStatus: row.syncStatus,
      lastSyncedAt: row.lastSyncedAt != null
          ? DateTime.parse(row.lastSyncedAt!)
          : null,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  factory DailyClosureModel.fromJson(Map<String, dynamic> json) {
    return DailyClosureModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      closureDate: json['closure_date'] as String,
      cutoffTimestamp: DateTime.parse(json['cutoff_timestamp'] as String),
      totalSalesAmount: (json['total_sales_amount'] as num).toInt(),
      totalCashDebtInflow:
          (json['total_cash_debt_inflow'] as num?)?.toInt() ?? 0,
      totalCreditSalesAmount:
          (json['total_credit_sales_amount'] as num?)?.toInt() ?? 0,
      totalExpensesAmount:
          (json['total_expenses_amount'] as num?)?.toInt() ?? 0,
      cashCounted: (json['cash_counted'] as num?)?.toInt() ?? 0,
      gpsLatitude: (json['gps_latitude'] as num?)?.toDouble(),
      gpsLongitude: (json['gps_longitude'] as num?)?.toDouble(),
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      isFlaggedLocation: json['is_flagged_location'] as bool? ?? false,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'closure_date': closureDate,
      'cutoff_timestamp': cutoffTimestamp.toUtc().toIso8601String(),
      'total_sales_amount': totalSalesAmount,
      'total_cash_debt_inflow': totalCashDebtInflow,
      'total_credit_sales_amount': totalCreditSalesAmount,
      'total_expenses_amount': totalExpensesAmount,
      'cash_counted': cashCounted,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'distance_meters': distanceMeters,
      'is_flagged_location': isFlaggedLocation,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  DailyClosuresCompanion toCompanion() {
    return DailyClosuresCompanion.insert(
      id: id,
      shopId: shopId,
      closureDate: closureDate,
      cutoffTimestamp: cutoffTimestamp.toUtc().toIso8601String(),
      totalSalesAmount: totalSalesAmount,
      totalCashDebtInflow: Value(totalCashDebtInflow),
      totalCreditSalesAmount: Value(totalCreditSalesAmount),
      totalExpensesAmount: Value(totalExpensesAmount),
      cashCounted: Value(cashCounted),
      gpsLatitude: Value(gpsLatitude),
      gpsLongitude: Value(gpsLongitude),
      distanceMeters: Value(distanceMeters),
      isFlaggedLocation: Value(isFlaggedLocation),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  DailyClosure toDrift() {
    return DailyClosure(
      id: id,
      shopId: shopId,
      closureDate: closureDate,
      cutoffTimestamp: cutoffTimestamp.toUtc().toIso8601String(),
      totalSalesAmount: totalSalesAmount,
      totalCashDebtInflow: totalCashDebtInflow,
      totalCreditSalesAmount: totalCreditSalesAmount,
      totalExpensesAmount: totalExpensesAmount,
      cashCounted: cashCounted,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      distanceMeters: distanceMeters,
      isFlaggedLocation: isFlaggedLocation,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt?.toUtc().toIso8601String(),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  DailyClosureEntity toEntity() {
    return DailyClosureEntity(
      id: id,
      shopId: shopId,
      closureDate: closureDate,
      cutoffTimestamp: cutoffTimestamp,
      totalSalesAmount: totalSalesAmount,
      totalCashDebtInflow: totalCashDebtInflow,
      totalCreditSalesAmount: totalCreditSalesAmount,
      totalExpensesAmount: totalExpensesAmount,
      cashCounted: cashCounted,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      distanceMeters: distanceMeters,
      isFlaggedLocation: isFlaggedLocation,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
    );
  }
}

extension DailyClosureDriftX on DailyClosure {
  DailyClosureEntity toEntity() => DailyClosureModel.fromDrift(this).toEntity();
}

extension DailyClosureEntityX on DailyClosureEntity {
  DailyClosuresCompanion toCompanion() {
    return DailyClosuresCompanion.insert(
      id: id,
      shopId: shopId,
      closureDate: closureDate,
      cutoffTimestamp: cutoffTimestamp.toUtc().toIso8601String(),
      totalSalesAmount: totalSalesAmount,
      totalCashDebtInflow: Value(totalCashDebtInflow),
      totalCreditSalesAmount: Value(totalCreditSalesAmount),
      totalExpensesAmount: Value(totalExpensesAmount),
      cashCounted: Value(cashCounted),
      gpsLatitude: Value(gpsLatitude),
      gpsLongitude: Value(gpsLongitude),
      distanceMeters: Value(distanceMeters),
      isFlaggedLocation: Value(isFlaggedLocation),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }
}
