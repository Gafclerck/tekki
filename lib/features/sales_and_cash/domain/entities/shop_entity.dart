import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  ShopEntity({
    required this.id,
    required this.name,
    required this.refLatitude,
    required this.refLongitude,
    required this.publicKey,
    this.syncStatus = 'pending',
    required DateTime createdAt,
  }) : createdAt = createdAt.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError('Shop id cannot be empty');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Shop name cannot be empty');
    }
    if (publicKey.trim().isEmpty) {
      throw ArgumentError('Shop public key cannot be empty');
    }
    if (refLatitude.isNaN || refLatitude < -90.0 || refLatitude > 90.0) {
      throw ArgumentError(
        'refLatitude must be a valid number between -90 and 90',
      );
    }
    if (refLongitude.isNaN || refLongitude < -180.0 || refLongitude > 180.0) {
      throw ArgumentError(
        'refLongitude must be a valid number between -180 and 180',
      );
    }
  }

  const ShopEntity.raw({
    required this.id,
    required this.name,
    required this.refLatitude,
    required this.refLongitude,
    required this.publicKey,
    this.syncStatus = 'pending',
    required this.createdAt,
  });

  final String id;
  final String name;
  final double refLatitude;
  final double refLongitude;
  final String publicKey;
  final String syncStatus;
  final DateTime createdAt;

  ShopEntity copyWith({
    String? id,
    String? name,
    double? refLatitude,
    double? refLongitude,
    String? publicKey,
    String? syncStatus,
    DateTime? createdAt,
  }) {
    return ShopEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      refLatitude: refLatitude ?? this.refLatitude,
      refLongitude: refLongitude ?? this.refLongitude,
      publicKey: publicKey ?? this.publicKey,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    refLatitude,
    refLongitude,
    publicKey,
    syncStatus,
    createdAt,
  ];
}
