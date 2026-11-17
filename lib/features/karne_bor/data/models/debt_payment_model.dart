import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';

class DebtPaymentModel extends DebtPaymentEntity {
  const DebtPaymentModel({
    required super.id,
    required super.debtId,
    required super.paymentAmount,
    super.paymentMethod = 'ESPECES',
    super.closureId,
    super.syncStatus = 'pending',
    super.lastSyncedAt,
    required super.paidAt,
  }) : super.raw();

  factory DebtPaymentModel.fromEntity(DebtPaymentEntity entity) {
    return DebtPaymentModel(
      id: entity.id,
      debtId: entity.debtId,
      paymentAmount: entity.paymentAmount,
      paymentMethod: entity.paymentMethod,
      closureId: entity.closureId,
      syncStatus: entity.syncStatus,
      lastSyncedAt: entity.lastSyncedAt,
      paidAt: entity.paidAt,
    );
  }

  factory DebtPaymentModel.fromDrift(DebtPayment row) {
    return DebtPaymentModel(
      id: row.id,
      debtId: row.debtId,
      paymentAmount: row.paymentAmount,
      paymentMethod: row.paymentMethod,
      closureId: row.closureId,
      syncStatus: row.syncStatus,
      lastSyncedAt:
          row.lastSyncedAt != null ? DateTime.parse(row.lastSyncedAt!) : null,
      paidAt: DateTime.parse(row.paidAt),
    );
  }

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) {
    return DebtPaymentModel(
      id: json['id'] as String,
      debtId: json['debt_id'] as String,
      paymentAmount: (json['payment_amount'] as num).toInt(),
      paymentMethod: json['payment_method'] as String? ?? 'ESPECES',
      closureId: json['closure_id'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      paidAt: DateTime.parse(json['paid_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debt_id': debtId,
      'payment_amount': paymentAmount,
      'payment_method': paymentMethod,
      'closure_id': closureId,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
      'paid_at': paidAt.toUtc().toIso8601String(),
    };
  }

  DebtPaymentsCompanion toCompanion() {
    return DebtPaymentsCompanion.insert(
      id: id,
      debtId: debtId,
      paymentAmount: paymentAmount,
      paymentMethod: Value(paymentMethod),
      closureId: Value(closureId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
      paidAt: paidAt.toUtc().toIso8601String(),
    );
  }

  DebtPayment toDrift() {
    return DebtPayment(
      id: id,
      debtId: debtId,
      paymentAmount: paymentAmount,
      paymentMethod: paymentMethod,
      closureId: closureId,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt?.toUtc().toIso8601String(),
      paidAt: paidAt.toUtc().toIso8601String(),
    );
  }

  DebtPaymentEntity toEntity() {
    return DebtPaymentEntity(
      id: id,
      debtId: debtId,
      paymentAmount: paymentAmount,
      paymentMethod: paymentMethod,
      closureId: closureId,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      paidAt: paidAt,
    );
  }
}
