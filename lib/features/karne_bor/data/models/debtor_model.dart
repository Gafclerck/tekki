import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

class DebtorModel extends DebtorEntity {
  const DebtorModel({
    required super.id,
    required super.name,
    super.phoneNumber,
    super.syncStatus = 'pending',
    required super.createdAt,
  });

  factory DebtorModel.fromEntity(DebtorEntity entity) {
    return DebtorModel(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      syncStatus: entity.syncStatus,
      createdAt: entity.createdAt,
    );
  }

  factory DebtorModel.fromDrift(Debtor row) {
    return DebtorModel(
      id: row.id,
      name: row.name,
      phoneNumber: row.phoneNumber,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  factory DebtorModel.fromJson(Map<String, dynamic> json) {
    return DebtorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'sync_status': syncStatus,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  DebtorsCompanion toCompanion() {
    return DebtorsCompanion.insert(
      id: id,
      name: name,
      phoneNumber: Value(phoneNumber),
      syncStatus: Value(syncStatus),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  Debtor toDrift() {
    return Debtor(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      syncStatus: syncStatus,
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  DebtorEntity toEntity() {
    return DebtorEntity(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      syncStatus: syncStatus,
      createdAt: createdAt,
    );
  }
}

extension DebtorDriftX on Debtor {
  DebtorEntity toEntity() => DebtorModel.fromDrift(this).toEntity();
}

extension DebtorEntityX on DebtorEntity {
  DebtorsCompanion toCompanion() {
    return DebtorsCompanion.insert(
      id: id,
      name: name,
      phoneNumber: Value(phoneNumber),
      syncStatus: Value(syncStatus),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }
}
