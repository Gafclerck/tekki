import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

class SaleModel extends SaleEntity {
  SaleModel({
    required super.id,
    required super.amount,
    required super.paymentMethod,
    required super.recordedAt,
    super.closureId,
    super.syncStatus = 'pending',
    super.lastSyncedAt,
  });

  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      recordedAt: entity.recordedAt,
      closureId: entity.closureId,
      syncStatus: entity.syncStatus,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }

  factory SaleModel.fromDrift(Sale row) {
    return SaleModel(
      id: row.id,
      amount: row.amount,
      paymentMethod: PaymentMethod.fromValue(row.paymentMethod),
      recordedAt: DateTime.parse(row.recordedAt),
      closureId: row.closureId,
      syncStatus: row.syncStatus,
      lastSyncedAt: row.lastSyncedAt != null
          ? DateTime.parse(row.lastSyncedAt!)
          : null,
    );
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      paymentMethod: PaymentMethod.fromValue(json['payment_method'] as String),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      closureId: json['closure_id'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'payment_method': paymentMethod.toValue(),
      'recorded_at': recordedAt.toUtc().toIso8601String(),
      'closure_id': closureId,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
    };
  }

  SalesCompanion toCompanion() {
    return SalesCompanion.insert(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod.toValue(),
      recordedAt: recordedAt.toUtc().toIso8601String(),
      closureId: Value(closureId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
    );
  }

  Sale toDrift() {
    return Sale(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod.toValue(),
      recordedAt: recordedAt.toUtc().toIso8601String(),
      closureId: closureId,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt?.toUtc().toIso8601String(),
    );
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod,
      recordedAt: recordedAt,
      closureId: closureId,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
    );
  }
}

extension SaleDriftX on Sale {
  SaleEntity toEntity() => SaleModel.fromDrift(this).toEntity();
}

extension SaleEntityX on SaleEntity {
  SalesCompanion toCompanion() {
    return SalesCompanion.insert(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod.toValue(),
      recordedAt: recordedAt.toUtc().toIso8601String(),
      closureId: Value(closureId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
    );
  }
}
