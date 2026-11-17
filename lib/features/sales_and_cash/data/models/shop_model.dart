import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  ShopModel({
    required super.id,
    required super.name,
    required super.refLatitude,
    required super.refLongitude,
    required super.publicKey,
    super.syncStatus = 'pending',
    required super.createdAt,
  });

  factory ShopModel.fromEntity(ShopEntity entity) {
    return ShopModel(
      id: entity.id,
      name: entity.name,
      refLatitude: entity.refLatitude,
      refLongitude: entity.refLongitude,
      publicKey: entity.publicKey,
      syncStatus: entity.syncStatus,
      createdAt: entity.createdAt,
    );
  }

  factory ShopModel.fromDrift(Shop row) {
    return ShopModel(
      id: row.id,
      name: row.name,
      refLatitude: row.refLatitude,
      refLongitude: row.refLongitude,
      publicKey: row.publicKey,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      refLatitude: (json['ref_latitude'] as num).toDouble(),
      refLongitude: (json['ref_longitude'] as num).toDouble(),
      publicKey: json['public_key'] as String,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ref_latitude': refLatitude,
      'ref_longitude': refLongitude,
      'public_key': publicKey,
      'sync_status': syncStatus,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  ShopsCompanion toCompanion() {
    return ShopsCompanion.insert(
      id: id,
      name: name,
      refLatitude: refLatitude,
      refLongitude: refLongitude,
      publicKey: publicKey,
      syncStatus: Value(syncStatus),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  Shop toDrift() {
    return Shop(
      id: id,
      name: name,
      refLatitude: refLatitude,
      refLongitude: refLongitude,
      publicKey: publicKey,
      syncStatus: syncStatus,
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }

  ShopEntity toEntity() {
    return ShopEntity(
      id: id,
      name: name,
      refLatitude: refLatitude,
      refLongitude: refLongitude,
      publicKey: publicKey,
      syncStatus: syncStatus,
      createdAt: createdAt,
    );
  }
}

extension ShopDriftX on Shop {
  ShopEntity toEntity() => ShopModel.fromDrift(this).toEntity();
}

extension ShopEntityX on ShopEntity {
  ShopsCompanion toCompanion() {
    return ShopsCompanion.insert(
      id: id,
      name: name,
      refLatitude: refLatitude,
      refLongitude: refLongitude,
      publicKey: publicKey,
      syncStatus: Value(syncStatus),
      createdAt: createdAt.toUtc().toIso8601String(),
    );
  }
}
