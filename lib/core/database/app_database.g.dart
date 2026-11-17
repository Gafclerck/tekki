// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShopsTable extends Shops with TableInfo<$ShopsTable, Shop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refLatitudeMeta = const VerificationMeta(
    'refLatitude',
  );
  @override
  late final GeneratedColumn<double> refLatitude = GeneratedColumn<double>(
    'ref_latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refLongitudeMeta = const VerificationMeta(
    'refLongitude',
  );
  @override
  late final GeneratedColumn<double> refLongitude = GeneratedColumn<double>(
    'ref_longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    refLatitude,
    refLongitude,
    publicKey,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ref_latitude')) {
      context.handle(
        _refLatitudeMeta,
        refLatitude.isAcceptableOrUnknown(
          data['ref_latitude']!,
          _refLatitudeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refLatitudeMeta);
    }
    if (data.containsKey('ref_longitude')) {
      context.handle(
        _refLongitudeMeta,
        refLongitude.isAcceptableOrUnknown(
          data['ref_longitude']!,
          _refLongitudeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refLongitudeMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      refLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ref_latitude'],
      )!,
      refLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ref_longitude'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShopsTable createAlias(String alias) {
    return $ShopsTable(attachedDatabase, alias);
  }
}

class Shop extends DataClass implements Insertable<Shop> {
  final String id;
  final String name;
  final double refLatitude;
  final double refLongitude;
  final String publicKey;
  final String syncStatus;
  final String createdAt;
  const Shop({
    required this.id,
    required this.name,
    required this.refLatitude,
    required this.refLongitude,
    required this.publicKey,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ref_latitude'] = Variable<double>(refLatitude);
    map['ref_longitude'] = Variable<double>(refLongitude);
    map['public_key'] = Variable<String>(publicKey);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
      id: Value(id),
      name: Value(name),
      refLatitude: Value(refLatitude),
      refLongitude: Value(refLongitude),
      publicKey: Value(publicKey),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Shop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shop(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      refLatitude: serializer.fromJson<double>(json['refLatitude']),
      refLongitude: serializer.fromJson<double>(json['refLongitude']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'refLatitude': serializer.toJson<double>(refLatitude),
      'refLongitude': serializer.toJson<double>(refLongitude),
      'publicKey': serializer.toJson<String>(publicKey),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    double? refLatitude,
    double? refLongitude,
    String? publicKey,
    String? syncStatus,
    String? createdAt,
  }) => Shop(
    id: id ?? this.id,
    name: name ?? this.name,
    refLatitude: refLatitude ?? this.refLatitude,
    refLongitude: refLongitude ?? this.refLongitude,
    publicKey: publicKey ?? this.publicKey,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  Shop copyWithCompanion(ShopsCompanion data) {
    return Shop(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      refLatitude: data.refLatitude.present
          ? data.refLatitude.value
          : this.refLatitude,
      refLongitude: data.refLongitude.present
          ? data.refLongitude.value
          : this.refLongitude,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shop(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('refLatitude: $refLatitude, ')
          ..write('refLongitude: $refLongitude, ')
          ..write('publicKey: $publicKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    refLatitude,
    refLongitude,
    publicKey,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shop &&
          other.id == this.id &&
          other.name == this.name &&
          other.refLatitude == this.refLatitude &&
          other.refLongitude == this.refLongitude &&
          other.publicKey == this.publicKey &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class ShopsCompanion extends UpdateCompanion<Shop> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> refLatitude;
  final Value<double> refLongitude;
  final Value<String> publicKey;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ShopsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.refLatitude = const Value.absent(),
    this.refLongitude = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopsCompanion.insert({
    required String id,
    required String name,
    required double refLatitude,
    required double refLongitude,
    required String publicKey,
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       refLatitude = Value(refLatitude),
       refLongitude = Value(refLongitude),
       publicKey = Value(publicKey),
       createdAt = Value(createdAt);
  static Insertable<Shop> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? refLatitude,
    Expression<double>? refLongitude,
    Expression<String>? publicKey,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (refLatitude != null) 'ref_latitude': refLatitude,
      if (refLongitude != null) 'ref_longitude': refLongitude,
      if (publicKey != null) 'public_key': publicKey,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? refLatitude,
    Value<double>? refLongitude,
    Value<String>? publicKey,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ShopsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      refLatitude: refLatitude ?? this.refLatitude,
      refLongitude: refLongitude ?? this.refLongitude,
      publicKey: publicKey ?? this.publicKey,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (refLatitude.present) {
      map['ref_latitude'] = Variable<double>(refLatitude.value);
    }
    if (refLongitude.present) {
      map['ref_longitude'] = Variable<double>(refLongitude.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('refLatitude: $refLatitude, ')
          ..write('refLongitude: $refLongitude, ')
          ..write('publicKey: $publicKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<String> recordedAt = GeneratedColumn<String>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closureIdMeta = const VerificationMeta(
    'closureId',
  );
  @override
  late final GeneratedColumn<String> closureId = GeneratedColumn<String>(
    'closure_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<String> lastSyncedAt = GeneratedColumn<String>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    paymentMethod,
    recordedAt,
    closureId,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('closure_id')) {
      context.handle(
        _closureIdMeta,
        closureId.isAcceptableOrUnknown(data['closure_id']!, _closureIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_at'],
      )!,
      closureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closure_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final int amount;
  final String paymentMethod;
  final String recordedAt;
  final String? closureId;
  final String syncStatus;
  final String? lastSyncedAt;
  const Sale({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.recordedAt,
    this.closureId,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['recorded_at'] = Variable<String>(recordedAt);
    if (!nullToAbsent || closureId != null) {
      map['closure_id'] = Variable<String>(closureId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      recordedAt: Value(recordedAt),
      closureId: closureId == null && nullToAbsent
          ? const Value.absent()
          : Value(closureId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      recordedAt: serializer.fromJson<String>(json['recordedAt']),
      closureId: serializer.fromJson<String?>(json['closureId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'recordedAt': serializer.toJson<String>(recordedAt),
      'closureId': serializer.toJson<String?>(closureId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
    };
  }

  Sale copyWith({
    String? id,
    int? amount,
    String? paymentMethod,
    String? recordedAt,
    Value<String?> closureId = const Value.absent(),
    String? syncStatus,
    Value<String?> lastSyncedAt = const Value.absent(),
  }) => Sale(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    recordedAt: recordedAt ?? this.recordedAt,
    closureId: closureId.present ? closureId.value : this.closureId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      closureId: data.closureId.present ? data.closureId.value : this.closureId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('closureId: $closureId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    paymentMethod,
    recordedAt,
    closureId,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.recordedAt == this.recordedAt &&
          other.closureId == this.closureId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<int> amount;
  final Value<String> paymentMethod;
  final Value<String> recordedAt;
  final Value<String?> closureId;
  final Value<String> syncStatus;
  final Value<String?> lastSyncedAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.closureId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required int amount,
    required String paymentMethod,
    required String recordedAt,
    this.closureId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       paymentMethod = Value(paymentMethod),
       recordedAt = Value(recordedAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<String>? paymentMethod,
    Expression<String>? recordedAt,
    Expression<String>? closureId,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (closureId != null) 'closure_id': closureId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<int>? amount,
    Value<String>? paymentMethod,
    Value<String>? recordedAt,
    Value<String?>? closureId,
    Value<String>? syncStatus,
    Value<String?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedAt: recordedAt ?? this.recordedAt,
      closureId: closureId ?? this.closureId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<String>(recordedAt.value);
    }
    if (closureId.present) {
      map['closure_id'] = Variable<String>(closureId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('closureId: $closureId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShopsTable shops = $ShopsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final Index salesClosureIdIdx = Index(
    'sales_closure_id_idx',
    'CREATE INDEX sales_closure_id_idx ON sales (closure_id)',
  );
  late final Index salesSyncStatusIdx = Index(
    'sales_sync_status_idx',
    'CREATE INDEX sales_sync_status_idx ON sales (sync_status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shops,
    sales,
    salesClosureIdIdx,
    salesSyncStatusIdx,
  ];
}

typedef $$ShopsTableCreateCompanionBuilder =
    ShopsCompanion Function({
      required String id,
      required String name,
      required double refLatitude,
      required double refLongitude,
      required String publicKey,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$ShopsTableUpdateCompanionBuilder =
    ShopsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> refLatitude,
      Value<double> refLongitude,
      Value<String> publicKey,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$ShopsTableFilterComposer extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refLatitude => $composableBuilder(
    column: $table.refLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refLongitude => $composableBuilder(
    column: $table.refLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refLatitude => $composableBuilder(
    column: $table.refLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refLongitude => $composableBuilder(
    column: $table.refLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get refLatitude => $composableBuilder(
    column: $table.refLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refLongitude => $composableBuilder(
    column: $table.refLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopsTable,
          Shop,
          $$ShopsTableFilterComposer,
          $$ShopsTableOrderingComposer,
          $$ShopsTableAnnotationComposer,
          $$ShopsTableCreateCompanionBuilder,
          $$ShopsTableUpdateCompanionBuilder,
          (Shop, BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
          Shop,
          PrefetchHooks Function()
        > {
  $$ShopsTableTableManager(_$AppDatabase db, $ShopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> refLatitude = const Value.absent(),
                Value<double> refLongitude = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion(
                id: id,
                name: name,
                refLatitude: refLatitude,
                refLongitude: refLongitude,
                publicKey: publicKey,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double refLatitude,
                required double refLongitude,
                required String publicKey,
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion.insert(
                id: id,
                name: name,
                refLatitude: refLatitude,
                refLongitude: refLongitude,
                publicKey: publicKey,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopsTable,
      Shop,
      $$ShopsTableFilterComposer,
      $$ShopsTableOrderingComposer,
      $$ShopsTableAnnotationComposer,
      $$ShopsTableCreateCompanionBuilder,
      $$ShopsTableUpdateCompanionBuilder,
      (Shop, BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
      Shop,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      required int amount,
      required String paymentMethod,
      required String recordedAt,
      Value<String?> closureId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<int> amount,
      Value<String> paymentMethod,
      Value<String> recordedAt,
      Value<String?> closureId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closureId => $composableBuilder(
    column: $table.closureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closureId => $composableBuilder(
    column: $table.closureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closureId =>
      $composableBuilder(column: $table.closureId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
          Sale,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> recordedAt = const Value.absent(),
                Value<String?> closureId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                amount: amount,
                paymentMethod: paymentMethod,
                recordedAt: recordedAt,
                closureId: closureId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amount,
                required String paymentMethod,
                required String recordedAt,
                Value<String?> closureId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                amount: amount,
                paymentMethod: paymentMethod,
                recordedAt: recordedAt,
                closureId: closureId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
      Sale,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
}
