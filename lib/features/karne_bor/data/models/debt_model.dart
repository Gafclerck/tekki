import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/data/models/debtor_model.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';

class DebtModel extends DebtEntity {
  const DebtModel({
    required super.id,
    required super.debtorId,
    required super.initialAmount,
    required super.remainingAmount,
    required super.dueDate,
    super.status = DebtStatus.active,
    super.syncStatus = 'pending',
    super.lastSyncedAt,
    required super.createdAt,
    super.debtor,
  });

  factory DebtModel.fromEntity(DebtEntity entity) {
    return DebtModel(
      id: entity.id,
      debtorId: entity.debtorId,
      initialAmount: entity.initialAmount,
      remainingAmount: entity.remainingAmount,
      dueDate: entity.dueDate,
      status: entity.status,
      syncStatus: entity.syncStatus,
      lastSyncedAt: entity.lastSyncedAt,
      createdAt: entity.createdAt,
      debtor: entity.debtor,
    );
  }

  factory DebtModel.fromDrift(Debt row, {Debtor? debtor}) {
    return DebtModel(
      id: row.id,
      debtorId: row.debtorId,
      initialAmount: row.initialAmount,
      remainingAmount: row.remainingAmount,
      dueDate: DateTime.parse(row.dueDate),
      status: DebtStatus.fromValue(row.status),
      syncStatus: row.syncStatus,
      lastSyncedAt: row.lastSyncedAt != null
          ? DateTime.parse(row.lastSyncedAt!)
          : null,
      createdAt: DateTime.parse(row.createdAt),
      debtor: debtor?.toEntity(),
    );
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      debtorId: json['debtor_id'] as String,
      initialAmount: (json['initial_amount'] as num).toInt(),
      remainingAmount: (json['remaining_amount'] as num).toInt(),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: DebtStatus.fromValue(json['status'] as String),
      syncStatus: json['sync_status'] as String? ?? 'pending',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      debtor: json['debtor'] != null
          ? DebtorModel.fromJson(
              json['debtor'] as Map<String, dynamic>,
            ).toEntity()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debtor_id': debtorId,
      'initial_amount': initialAmount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate.toUtc().toIso8601String(),
      'status': status.toValue(),
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'debtor': debtor != null
          ? DebtorModel.fromEntity(debtor!).toJson()
          : null,
    };
  }

  DebtsCompanion toCompanion() {
    return DebtsCompanion.insert(
      id: id,
      debtorId: debtorId,
      initialAmount: initialAmount,
      remainingAmount: remainingAmount,
      dueDate: dueDate.toUtc().toIso8601String(),
      status: Value(status.toValue()),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  Debt toDrift() {
    return Debt(
      id: id,
      debtorId: debtorId,
      initialAmount: initialAmount,
      remainingAmount: remainingAmount,
      dueDate: dueDate.toUtc().toIso8601String(),
      status: status.toValue(),
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt?.toUtc().toIso8601String(),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  DebtEntity toEntity() {
    return DebtEntity(
      id: id,
      debtorId: debtorId,
      initialAmount: initialAmount,
      remainingAmount: remainingAmount,
      dueDate: dueDate,
      status: status,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
      debtor: debtor,
    );
  }
}

extension DebtDriftX on Debt {
  DebtEntity toEntity({Debtor? debtor}) =>
      DebtModel.fromDrift(this, debtor: debtor).toEntity();
}

extension DebtEntityX on DebtEntity {
  DebtsCompanion toCompanion() {
    return DebtsCompanion.insert(
      id: id,
      debtorId: debtorId,
      initialAmount: initialAmount,
      remainingAmount: remainingAmount,
      dueDate: dueDate.toUtc().toIso8601String(),
      status: Value(status.toValue()),
      syncStatus: Value(syncStatus),
      lastSyncedAt: Value(lastSyncedAt?.toUtc().toIso8601String()),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }
}
