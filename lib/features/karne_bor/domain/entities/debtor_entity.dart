class DebtorEntity {
  const DebtorEntity({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.syncStatus = 'pending',
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phoneNumber;
  final String syncStatus;
  final DateTime createdAt;

  DebtorEntity copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? syncStatus,
    DateTime? createdAt,
  }) {
    return DebtorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtorEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          syncStatus == other.syncStatus &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, phoneNumber, syncStatus, createdAt);

  @override
  String toString() {
    return 'DebtorEntity(id: $id, name: $name, phone: $phoneNumber, sync: $syncStatus, createdAt: $createdAt)';
  }
}
