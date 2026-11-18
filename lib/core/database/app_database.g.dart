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

class $DailyClosuresTable extends DailyClosures
    with TableInfo<$DailyClosuresTable, DailyClosure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClosuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closureDateMeta = const VerificationMeta(
    'closureDate',
  );
  @override
  late final GeneratedColumn<String> closureDate = GeneratedColumn<String>(
    'closure_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cutoffTimestampMeta = const VerificationMeta(
    'cutoffTimestamp',
  );
  @override
  late final GeneratedColumn<String> cutoffTimestamp = GeneratedColumn<String>(
    'cutoff_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSalesAmountMeta = const VerificationMeta(
    'totalSalesAmount',
  );
  @override
  late final GeneratedColumn<int> totalSalesAmount = GeneratedColumn<int>(
    'total_sales_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCashDebtInflowMeta =
      const VerificationMeta('totalCashDebtInflow');
  @override
  late final GeneratedColumn<int> totalCashDebtInflow = GeneratedColumn<int>(
    'total_cash_debt_inflow',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCreditSalesAmountMeta =
      const VerificationMeta('totalCreditSalesAmount');
  @override
  late final GeneratedColumn<int> totalCreditSalesAmount = GeneratedColumn<int>(
    'total_credit_sales_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalExpensesAmountMeta =
      const VerificationMeta('totalExpensesAmount');
  @override
  late final GeneratedColumn<int> totalExpensesAmount = GeneratedColumn<int>(
    'total_expenses_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cashCountedMeta = const VerificationMeta(
    'cashCounted',
  );
  @override
  late final GeneratedColumn<int> cashCounted = GeneratedColumn<int>(
    'cash_counted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gpsLatitudeMeta = const VerificationMeta(
    'gpsLatitude',
  );
  @override
  late final GeneratedColumn<double> gpsLatitude = GeneratedColumn<double>(
    'gps_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsLongitudeMeta = const VerificationMeta(
    'gpsLongitude',
  );
  @override
  late final GeneratedColumn<double> gpsLongitude = GeneratedColumn<double>(
    'gps_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFlaggedLocationMeta = const VerificationMeta(
    'isFlaggedLocation',
  );
  @override
  late final GeneratedColumn<bool> isFlaggedLocation = GeneratedColumn<bool>(
    'is_flagged_location',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_flagged_location" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closures';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyClosure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('closure_date')) {
      context.handle(
        _closureDateMeta,
        closureDate.isAcceptableOrUnknown(
          data['closure_date']!,
          _closureDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_closureDateMeta);
    }
    if (data.containsKey('cutoff_timestamp')) {
      context.handle(
        _cutoffTimestampMeta,
        cutoffTimestamp.isAcceptableOrUnknown(
          data['cutoff_timestamp']!,
          _cutoffTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cutoffTimestampMeta);
    }
    if (data.containsKey('total_sales_amount')) {
      context.handle(
        _totalSalesAmountMeta,
        totalSalesAmount.isAcceptableOrUnknown(
          data['total_sales_amount']!,
          _totalSalesAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalSalesAmountMeta);
    }
    if (data.containsKey('total_cash_debt_inflow')) {
      context.handle(
        _totalCashDebtInflowMeta,
        totalCashDebtInflow.isAcceptableOrUnknown(
          data['total_cash_debt_inflow']!,
          _totalCashDebtInflowMeta,
        ),
      );
    }
    if (data.containsKey('total_credit_sales_amount')) {
      context.handle(
        _totalCreditSalesAmountMeta,
        totalCreditSalesAmount.isAcceptableOrUnknown(
          data['total_credit_sales_amount']!,
          _totalCreditSalesAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_expenses_amount')) {
      context.handle(
        _totalExpensesAmountMeta,
        totalExpensesAmount.isAcceptableOrUnknown(
          data['total_expenses_amount']!,
          _totalExpensesAmountMeta,
        ),
      );
    }
    if (data.containsKey('cash_counted')) {
      context.handle(
        _cashCountedMeta,
        cashCounted.isAcceptableOrUnknown(
          data['cash_counted']!,
          _cashCountedMeta,
        ),
      );
    }
    if (data.containsKey('gps_latitude')) {
      context.handle(
        _gpsLatitudeMeta,
        gpsLatitude.isAcceptableOrUnknown(
          data['gps_latitude']!,
          _gpsLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('gps_longitude')) {
      context.handle(
        _gpsLongitudeMeta,
        gpsLongitude.isAcceptableOrUnknown(
          data['gps_longitude']!,
          _gpsLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_flagged_location')) {
      context.handle(
        _isFlaggedLocationMeta,
        isFlaggedLocation.isAcceptableOrUnknown(
          data['is_flagged_location']!,
          _isFlaggedLocationMeta,
        ),
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
  DailyClosure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClosure(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      closureDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closure_date'],
      )!,
      cutoffTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cutoff_timestamp'],
      )!,
      totalSalesAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sales_amount'],
      )!,
      totalCashDebtInflow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cash_debt_inflow'],
      )!,
      totalCreditSalesAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_credit_sales_amount'],
      )!,
      totalExpensesAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expenses_amount'],
      )!,
      cashCounted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_counted'],
      )!,
      gpsLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_latitude'],
      ),
      gpsLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_longitude'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      isFlaggedLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_flagged_location'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyClosuresTable createAlias(String alias) {
    return $DailyClosuresTable(attachedDatabase, alias);
  }
}

class DailyClosure extends DataClass implements Insertable<DailyClosure> {
  final String id;
  final String shopId;
  final String closureDate;
  final String cutoffTimestamp;
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
  final String? lastSyncedAt;
  final String createdAt;
  const DailyClosure({
    required this.id,
    required this.shopId,
    required this.closureDate,
    required this.cutoffTimestamp,
    required this.totalSalesAmount,
    required this.totalCashDebtInflow,
    required this.totalCreditSalesAmount,
    required this.totalExpensesAmount,
    required this.cashCounted,
    this.gpsLatitude,
    this.gpsLongitude,
    this.distanceMeters,
    required this.isFlaggedLocation,
    required this.syncStatus,
    this.lastSyncedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['closure_date'] = Variable<String>(closureDate);
    map['cutoff_timestamp'] = Variable<String>(cutoffTimestamp);
    map['total_sales_amount'] = Variable<int>(totalSalesAmount);
    map['total_cash_debt_inflow'] = Variable<int>(totalCashDebtInflow);
    map['total_credit_sales_amount'] = Variable<int>(totalCreditSalesAmount);
    map['total_expenses_amount'] = Variable<int>(totalExpensesAmount);
    map['cash_counted'] = Variable<int>(cashCounted);
    if (!nullToAbsent || gpsLatitude != null) {
      map['gps_latitude'] = Variable<double>(gpsLatitude);
    }
    if (!nullToAbsent || gpsLongitude != null) {
      map['gps_longitude'] = Variable<double>(gpsLongitude);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    map['is_flagged_location'] = Variable<bool>(isFlaggedLocation);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  DailyClosuresCompanion toCompanion(bool nullToAbsent) {
    return DailyClosuresCompanion(
      id: Value(id),
      shopId: Value(shopId),
      closureDate: Value(closureDate),
      cutoffTimestamp: Value(cutoffTimestamp),
      totalSalesAmount: Value(totalSalesAmount),
      totalCashDebtInflow: Value(totalCashDebtInflow),
      totalCreditSalesAmount: Value(totalCreditSalesAmount),
      totalExpensesAmount: Value(totalExpensesAmount),
      cashCounted: Value(cashCounted),
      gpsLatitude: gpsLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLatitude),
      gpsLongitude: gpsLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLongitude),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      isFlaggedLocation: Value(isFlaggedLocation),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
    );
  }

  factory DailyClosure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClosure(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      closureDate: serializer.fromJson<String>(json['closureDate']),
      cutoffTimestamp: serializer.fromJson<String>(json['cutoffTimestamp']),
      totalSalesAmount: serializer.fromJson<int>(json['totalSalesAmount']),
      totalCashDebtInflow: serializer.fromJson<int>(
        json['totalCashDebtInflow'],
      ),
      totalCreditSalesAmount: serializer.fromJson<int>(
        json['totalCreditSalesAmount'],
      ),
      totalExpensesAmount: serializer.fromJson<int>(
        json['totalExpensesAmount'],
      ),
      cashCounted: serializer.fromJson<int>(json['cashCounted']),
      gpsLatitude: serializer.fromJson<double?>(json['gpsLatitude']),
      gpsLongitude: serializer.fromJson<double?>(json['gpsLongitude']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      isFlaggedLocation: serializer.fromJson<bool>(json['isFlaggedLocation']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'closureDate': serializer.toJson<String>(closureDate),
      'cutoffTimestamp': serializer.toJson<String>(cutoffTimestamp),
      'totalSalesAmount': serializer.toJson<int>(totalSalesAmount),
      'totalCashDebtInflow': serializer.toJson<int>(totalCashDebtInflow),
      'totalCreditSalesAmount': serializer.toJson<int>(totalCreditSalesAmount),
      'totalExpensesAmount': serializer.toJson<int>(totalExpensesAmount),
      'cashCounted': serializer.toJson<int>(cashCounted),
      'gpsLatitude': serializer.toJson<double?>(gpsLatitude),
      'gpsLongitude': serializer.toJson<double?>(gpsLongitude),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'isFlaggedLocation': serializer.toJson<bool>(isFlaggedLocation),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  DailyClosure copyWith({
    String? id,
    String? shopId,
    String? closureDate,
    String? cutoffTimestamp,
    int? totalSalesAmount,
    int? totalCashDebtInflow,
    int? totalCreditSalesAmount,
    int? totalExpensesAmount,
    int? cashCounted,
    Value<double?> gpsLatitude = const Value.absent(),
    Value<double?> gpsLongitude = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    bool? isFlaggedLocation,
    String? syncStatus,
    Value<String?> lastSyncedAt = const Value.absent(),
    String? createdAt,
  }) => DailyClosure(
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
    gpsLatitude: gpsLatitude.present ? gpsLatitude.value : this.gpsLatitude,
    gpsLongitude: gpsLongitude.present ? gpsLongitude.value : this.gpsLongitude,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    isFlaggedLocation: isFlaggedLocation ?? this.isFlaggedLocation,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyClosure copyWithCompanion(DailyClosuresCompanion data) {
    return DailyClosure(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      closureDate: data.closureDate.present
          ? data.closureDate.value
          : this.closureDate,
      cutoffTimestamp: data.cutoffTimestamp.present
          ? data.cutoffTimestamp.value
          : this.cutoffTimestamp,
      totalSalesAmount: data.totalSalesAmount.present
          ? data.totalSalesAmount.value
          : this.totalSalesAmount,
      totalCashDebtInflow: data.totalCashDebtInflow.present
          ? data.totalCashDebtInflow.value
          : this.totalCashDebtInflow,
      totalCreditSalesAmount: data.totalCreditSalesAmount.present
          ? data.totalCreditSalesAmount.value
          : this.totalCreditSalesAmount,
      totalExpensesAmount: data.totalExpensesAmount.present
          ? data.totalExpensesAmount.value
          : this.totalExpensesAmount,
      cashCounted: data.cashCounted.present
          ? data.cashCounted.value
          : this.cashCounted,
      gpsLatitude: data.gpsLatitude.present
          ? data.gpsLatitude.value
          : this.gpsLatitude,
      gpsLongitude: data.gpsLongitude.present
          ? data.gpsLongitude.value
          : this.gpsLongitude,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      isFlaggedLocation: data.isFlaggedLocation.present
          ? data.isFlaggedLocation.value
          : this.isFlaggedLocation,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosure(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('closureDate: $closureDate, ')
          ..write('cutoffTimestamp: $cutoffTimestamp, ')
          ..write('totalSalesAmount: $totalSalesAmount, ')
          ..write('totalCashDebtInflow: $totalCashDebtInflow, ')
          ..write('totalCreditSalesAmount: $totalCreditSalesAmount, ')
          ..write('totalExpensesAmount: $totalExpensesAmount, ')
          ..write('cashCounted: $cashCounted, ')
          ..write('gpsLatitude: $gpsLatitude, ')
          ..write('gpsLongitude: $gpsLongitude, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('isFlaggedLocation: $isFlaggedLocation, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClosure &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.closureDate == this.closureDate &&
          other.cutoffTimestamp == this.cutoffTimestamp &&
          other.totalSalesAmount == this.totalSalesAmount &&
          other.totalCashDebtInflow == this.totalCashDebtInflow &&
          other.totalCreditSalesAmount == this.totalCreditSalesAmount &&
          other.totalExpensesAmount == this.totalExpensesAmount &&
          other.cashCounted == this.cashCounted &&
          other.gpsLatitude == this.gpsLatitude &&
          other.gpsLongitude == this.gpsLongitude &&
          other.distanceMeters == this.distanceMeters &&
          other.isFlaggedLocation == this.isFlaggedLocation &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt);
}

class DailyClosuresCompanion extends UpdateCompanion<DailyClosure> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> closureDate;
  final Value<String> cutoffTimestamp;
  final Value<int> totalSalesAmount;
  final Value<int> totalCashDebtInflow;
  final Value<int> totalCreditSalesAmount;
  final Value<int> totalExpensesAmount;
  final Value<int> cashCounted;
  final Value<double?> gpsLatitude;
  final Value<double?> gpsLongitude;
  final Value<double?> distanceMeters;
  final Value<bool> isFlaggedLocation;
  final Value<String> syncStatus;
  final Value<String?> lastSyncedAt;
  final Value<String> createdAt;
  final Value<int> rowid;
  const DailyClosuresCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.closureDate = const Value.absent(),
    this.cutoffTimestamp = const Value.absent(),
    this.totalSalesAmount = const Value.absent(),
    this.totalCashDebtInflow = const Value.absent(),
    this.totalCreditSalesAmount = const Value.absent(),
    this.totalExpensesAmount = const Value.absent(),
    this.cashCounted = const Value.absent(),
    this.gpsLatitude = const Value.absent(),
    this.gpsLongitude = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.isFlaggedLocation = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyClosuresCompanion.insert({
    required String id,
    required String shopId,
    required String closureDate,
    required String cutoffTimestamp,
    required int totalSalesAmount,
    this.totalCashDebtInflow = const Value.absent(),
    this.totalCreditSalesAmount = const Value.absent(),
    this.totalExpensesAmount = const Value.absent(),
    this.cashCounted = const Value.absent(),
    this.gpsLatitude = const Value.absent(),
    this.gpsLongitude = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.isFlaggedLocation = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       closureDate = Value(closureDate),
       cutoffTimestamp = Value(cutoffTimestamp),
       totalSalesAmount = Value(totalSalesAmount),
       createdAt = Value(createdAt);
  static Insertable<DailyClosure> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? closureDate,
    Expression<String>? cutoffTimestamp,
    Expression<int>? totalSalesAmount,
    Expression<int>? totalCashDebtInflow,
    Expression<int>? totalCreditSalesAmount,
    Expression<int>? totalExpensesAmount,
    Expression<int>? cashCounted,
    Expression<double>? gpsLatitude,
    Expression<double>? gpsLongitude,
    Expression<double>? distanceMeters,
    Expression<bool>? isFlaggedLocation,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncedAt,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (closureDate != null) 'closure_date': closureDate,
      if (cutoffTimestamp != null) 'cutoff_timestamp': cutoffTimestamp,
      if (totalSalesAmount != null) 'total_sales_amount': totalSalesAmount,
      if (totalCashDebtInflow != null)
        'total_cash_debt_inflow': totalCashDebtInflow,
      if (totalCreditSalesAmount != null)
        'total_credit_sales_amount': totalCreditSalesAmount,
      if (totalExpensesAmount != null)
        'total_expenses_amount': totalExpensesAmount,
      if (cashCounted != null) 'cash_counted': cashCounted,
      if (gpsLatitude != null) 'gps_latitude': gpsLatitude,
      if (gpsLongitude != null) 'gps_longitude': gpsLongitude,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (isFlaggedLocation != null) 'is_flagged_location': isFlaggedLocation,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyClosuresCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? closureDate,
    Value<String>? cutoffTimestamp,
    Value<int>? totalSalesAmount,
    Value<int>? totalCashDebtInflow,
    Value<int>? totalCreditSalesAmount,
    Value<int>? totalExpensesAmount,
    Value<int>? cashCounted,
    Value<double?>? gpsLatitude,
    Value<double?>? gpsLongitude,
    Value<double?>? distanceMeters,
    Value<bool>? isFlaggedLocation,
    Value<String>? syncStatus,
    Value<String?>? lastSyncedAt,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyClosuresCompanion(
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
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isFlaggedLocation: isFlaggedLocation ?? this.isFlaggedLocation,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
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
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (closureDate.present) {
      map['closure_date'] = Variable<String>(closureDate.value);
    }
    if (cutoffTimestamp.present) {
      map['cutoff_timestamp'] = Variable<String>(cutoffTimestamp.value);
    }
    if (totalSalesAmount.present) {
      map['total_sales_amount'] = Variable<int>(totalSalesAmount.value);
    }
    if (totalCashDebtInflow.present) {
      map['total_cash_debt_inflow'] = Variable<int>(totalCashDebtInflow.value);
    }
    if (totalCreditSalesAmount.present) {
      map['total_credit_sales_amount'] = Variable<int>(
        totalCreditSalesAmount.value,
      );
    }
    if (totalExpensesAmount.present) {
      map['total_expenses_amount'] = Variable<int>(totalExpensesAmount.value);
    }
    if (cashCounted.present) {
      map['cash_counted'] = Variable<int>(cashCounted.value);
    }
    if (gpsLatitude.present) {
      map['gps_latitude'] = Variable<double>(gpsLatitude.value);
    }
    if (gpsLongitude.present) {
      map['gps_longitude'] = Variable<double>(gpsLongitude.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (isFlaggedLocation.present) {
      map['is_flagged_location'] = Variable<bool>(isFlaggedLocation.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
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
    return (StringBuffer('DailyClosuresCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('closureDate: $closureDate, ')
          ..write('cutoffTimestamp: $cutoffTimestamp, ')
          ..write('totalSalesAmount: $totalSalesAmount, ')
          ..write('totalCashDebtInflow: $totalCashDebtInflow, ')
          ..write('totalCreditSalesAmount: $totalCreditSalesAmount, ')
          ..write('totalExpensesAmount: $totalExpensesAmount, ')
          ..write('cashCounted: $cashCounted, ')
          ..write('gpsLatitude: $gpsLatitude, ')
          ..write('gpsLongitude: $gpsLongitude, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('isFlaggedLocation: $isFlaggedLocation, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtorsTable extends Debtors with TableInfo<$DebtorsTable, Debtor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
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
    phoneNumber,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debtors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debtor> instance, {
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
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
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
  Debtor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debtor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
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
  $DebtorsTable createAlias(String alias) {
    return $DebtorsTable(attachedDatabase, alias);
  }
}

class Debtor extends DataClass implements Insertable<Debtor> {
  final String id;
  final String name;
  final String? phoneNumber;
  final String syncStatus;
  final String createdAt;
  const Debtor({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  DebtorsCompanion toCompanion(bool nullToAbsent) {
    return DebtorsCompanion(
      id: Value(id),
      name: Value(name),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Debtor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debtor(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
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
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Debtor copyWith({
    String? id,
    String? name,
    Value<String?> phoneNumber = const Value.absent(),
    String? syncStatus,
    String? createdAt,
  }) => Debtor(
    id: id ?? this.id,
    name: name ?? this.name,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  Debtor copyWithCompanion(DebtorsCompanion data) {
    return Debtor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debtor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phoneNumber, syncStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debtor &&
          other.id == this.id &&
          other.name == this.name &&
          other.phoneNumber == this.phoneNumber &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class DebtorsCompanion extends UpdateCompanion<Debtor> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phoneNumber;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const DebtorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtorsCompanion.insert({
    required String id,
    required String name,
    this.phoneNumber = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Debtor> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phoneNumber,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phoneNumber,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return DebtorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
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
    return (StringBuffer('DebtorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtorIdMeta = const VerificationMeta(
    'debtorId',
  );
  @override
  late final GeneratedColumn<String> debtorId = GeneratedColumn<String>(
    'debtor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debtors (id)',
    ),
  );
  static const VerificationMeta _initialAmountMeta = const VerificationMeta(
    'initialAmount',
  );
  @override
  late final GeneratedColumn<int> initialAmount = GeneratedColumn<int>(
    'initial_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingAmountMeta = const VerificationMeta(
    'remainingAmount',
  );
  @override
  late final GeneratedColumn<int> remainingAmount = GeneratedColumn<int>(
    'remaining_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
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
    debtorId,
    initialAmount,
    remainingAmount,
    dueDate,
    status,
    syncStatus,
    lastSyncedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debtor_id')) {
      context.handle(
        _debtorIdMeta,
        debtorId.isAcceptableOrUnknown(data['debtor_id']!, _debtorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtorIdMeta);
    }
    if (data.containsKey('initial_amount')) {
      context.handle(
        _initialAmountMeta,
        initialAmount.isAcceptableOrUnknown(
          data['initial_amount']!,
          _initialAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialAmountMeta);
    }
    if (data.containsKey('remaining_amount')) {
      context.handle(
        _remainingAmountMeta,
        remainingAmount.isAcceptableOrUnknown(
          data['remaining_amount']!,
          _remainingAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingAmountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debtor_id'],
      )!,
      initialAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_amount'],
      )!,
      remainingAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_amount'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final String id;
  final String debtorId;
  final int initialAmount;
  final int remainingAmount;
  final String dueDate;
  final String status;
  final String syncStatus;
  final String? lastSyncedAt;
  final String createdAt;
  const Debt({
    required this.id,
    required this.debtorId,
    required this.initialAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
    required this.syncStatus,
    this.lastSyncedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debtor_id'] = Variable<String>(debtorId);
    map['initial_amount'] = Variable<int>(initialAmount);
    map['remaining_amount'] = Variable<int>(remainingAmount);
    map['due_date'] = Variable<String>(dueDate);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      debtorId: Value(debtorId),
      initialAmount: Value(initialAmount),
      remainingAmount: Value(remainingAmount),
      dueDate: Value(dueDate),
      status: Value(status),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<String>(json['id']),
      debtorId: serializer.fromJson<String>(json['debtorId']),
      initialAmount: serializer.fromJson<int>(json['initialAmount']),
      remainingAmount: serializer.fromJson<int>(json['remainingAmount']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtorId': serializer.toJson<String>(debtorId),
      'initialAmount': serializer.toJson<int>(initialAmount),
      'remainingAmount': serializer.toJson<int>(remainingAmount),
      'dueDate': serializer.toJson<String>(dueDate),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Debt copyWith({
    String? id,
    String? debtorId,
    int? initialAmount,
    int? remainingAmount,
    String? dueDate,
    String? status,
    String? syncStatus,
    Value<String?> lastSyncedAt = const Value.absent(),
    String? createdAt,
  }) => Debt(
    id: id ?? this.id,
    debtorId: debtorId ?? this.debtorId,
    initialAmount: initialAmount ?? this.initialAmount,
    remainingAmount: remainingAmount ?? this.remainingAmount,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      debtorId: data.debtorId.present ? data.debtorId.value : this.debtorId,
      initialAmount: data.initialAmount.present
          ? data.initialAmount.value
          : this.initialAmount,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('debtorId: $debtorId, ')
          ..write('initialAmount: $initialAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtorId,
    initialAmount,
    remainingAmount,
    dueDate,
    status,
    syncStatus,
    lastSyncedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.debtorId == this.debtorId &&
          other.initialAmount == this.initialAmount &&
          other.remainingAmount == this.remainingAmount &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<String> id;
  final Value<String> debtorId;
  final Value<int> initialAmount;
  final Value<int> remainingAmount;
  final Value<String> dueDate;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<String?> lastSyncedAt;
  final Value<String> createdAt;
  final Value<int> rowid;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.debtorId = const Value.absent(),
    this.initialAmount = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    required String id,
    required String debtorId,
    required int initialAmount,
    required int remainingAmount,
    required String dueDate,
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtorId = Value(debtorId),
       initialAmount = Value(initialAmount),
       remainingAmount = Value(remainingAmount),
       dueDate = Value(dueDate),
       createdAt = Value(createdAt);
  static Insertable<Debt> custom({
    Expression<String>? id,
    Expression<String>? debtorId,
    Expression<int>? initialAmount,
    Expression<int>? remainingAmount,
    Expression<String>? dueDate,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncedAt,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtorId != null) 'debtor_id': debtorId,
      if (initialAmount != null) 'initial_amount': initialAmount,
      if (remainingAmount != null) 'remaining_amount': remainingAmount,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith({
    Value<String>? id,
    Value<String>? debtorId,
    Value<int>? initialAmount,
    Value<int>? remainingAmount,
    Value<String>? dueDate,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<String?>? lastSyncedAt,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      initialAmount: initialAmount ?? this.initialAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
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
    if (debtorId.present) {
      map['debtor_id'] = Variable<String>(debtorId.value);
    }
    if (initialAmount.present) {
      map['initial_amount'] = Variable<int>(initialAmount.value);
    }
    if (remainingAmount.present) {
      map['remaining_amount'] = Variable<int>(remainingAmount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
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
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('debtorId: $debtorId, ')
          ..write('initialAmount: $initialAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtPaymentsTable extends DebtPayments
    with TableInfo<$DebtPaymentsTable, DebtPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts (id)',
    ),
  );
  static const VerificationMeta _paymentAmountMeta = const VerificationMeta(
    'paymentAmount',
  );
  @override
  late final GeneratedColumn<int> paymentAmount = GeneratedColumn<int>(
    'payment_amount',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('ESPECES'),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_closures (id)',
    ),
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
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<String> paidAt = GeneratedColumn<String>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtId,
    paymentAmount,
    paymentMethod,
    closureId,
    syncStatus,
    lastSyncedAt,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('payment_amount')) {
      context.handle(
        _paymentAmountMeta,
        paymentAmount.isAcceptableOrUnknown(
          data['payment_amount']!,
          _paymentAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentAmountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
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
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      paymentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
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
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $DebtPaymentsTable createAlias(String alias) {
    return $DebtPaymentsTable(attachedDatabase, alias);
  }
}

class DebtPayment extends DataClass implements Insertable<DebtPayment> {
  final String id;
  final String debtId;
  final int paymentAmount;
  final String paymentMethod;
  final String? closureId;
  final String syncStatus;
  final String? lastSyncedAt;
  final String paidAt;
  const DebtPayment({
    required this.id,
    required this.debtId,
    required this.paymentAmount,
    required this.paymentMethod,
    this.closureId,
    required this.syncStatus,
    this.lastSyncedAt,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debt_id'] = Variable<String>(debtId);
    map['payment_amount'] = Variable<int>(paymentAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || closureId != null) {
      map['closure_id'] = Variable<String>(closureId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    map['paid_at'] = Variable<String>(paidAt);
    return map;
  }

  DebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtPaymentsCompanion(
      id: Value(id),
      debtId: Value(debtId),
      paymentAmount: Value(paymentAmount),
      paymentMethod: Value(paymentMethod),
      closureId: closureId == null && nullToAbsent
          ? const Value.absent()
          : Value(closureId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      paidAt: Value(paidAt),
    );
  }

  factory DebtPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtPayment(
      id: serializer.fromJson<String>(json['id']),
      debtId: serializer.fromJson<String>(json['debtId']),
      paymentAmount: serializer.fromJson<int>(json['paymentAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      closureId: serializer.fromJson<String?>(json['closureId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      paidAt: serializer.fromJson<String>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtId': serializer.toJson<String>(debtId),
      'paymentAmount': serializer.toJson<int>(paymentAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'closureId': serializer.toJson<String?>(closureId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'paidAt': serializer.toJson<String>(paidAt),
    };
  }

  DebtPayment copyWith({
    String? id,
    String? debtId,
    int? paymentAmount,
    String? paymentMethod,
    Value<String?> closureId = const Value.absent(),
    String? syncStatus,
    Value<String?> lastSyncedAt = const Value.absent(),
    String? paidAt,
  }) => DebtPayment(
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    paymentAmount: paymentAmount ?? this.paymentAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    closureId: closureId.present ? closureId.value : this.closureId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    paidAt: paidAt ?? this.paidAt,
  );
  DebtPayment copyWithCompanion(DebtPaymentsCompanion data) {
    return DebtPayment(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      paymentAmount: data.paymentAmount.present
          ? data.paymentAmount.value
          : this.paymentAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      closureId: data.closureId.present ? data.closureId.value : this.closureId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtPayment(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('closureId: $closureId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtId,
    paymentAmount,
    paymentMethod,
    closureId,
    syncStatus,
    lastSyncedAt,
    paidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtPayment &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.paymentAmount == this.paymentAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.closureId == this.closureId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.paidAt == this.paidAt);
}

class DebtPaymentsCompanion extends UpdateCompanion<DebtPayment> {
  final Value<String> id;
  final Value<String> debtId;
  final Value<int> paymentAmount;
  final Value<String> paymentMethod;
  final Value<String?> closureId;
  final Value<String> syncStatus;
  final Value<String?> lastSyncedAt;
  final Value<String> paidAt;
  final Value<int> rowid;
  const DebtPaymentsCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.closureId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtPaymentsCompanion.insert({
    required String id,
    required String debtId,
    required int paymentAmount,
    this.paymentMethod = const Value.absent(),
    this.closureId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String paidAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId),
       paymentAmount = Value(paymentAmount),
       paidAt = Value(paidAt);
  static Insertable<DebtPayment> custom({
    Expression<String>? id,
    Expression<String>? debtId,
    Expression<int>? paymentAmount,
    Expression<String>? paymentMethod,
    Expression<String>? closureId,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncedAt,
    Expression<String>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (closureId != null) 'closure_id': closureId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? debtId,
    Value<int>? paymentAmount,
    Value<String>? paymentMethod,
    Value<String?>? closureId,
    Value<String>? syncStatus,
    Value<String?>? lastSyncedAt,
    Value<String>? paidAt,
    Value<int>? rowid,
  }) {
    return DebtPaymentsCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      closureId: closureId ?? this.closureId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (paymentAmount.present) {
      map['payment_amount'] = Variable<int>(paymentAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
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
    if (paidAt.present) {
      map['paid_at'] = Variable<String>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('closureId: $closureId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientEventIdMeta = const VerificationMeta(
    'clientEventId',
  );
  @override
  late final GeneratedColumn<String> clientEventId = GeneratedColumn<String>(
    'client_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
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
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<String> lastAttemptAt = GeneratedColumn<String>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientEventId,
    eventType,
    targetTable,
    targetId,
    payloadJson,
    retryCount,
    status,
    createdAt,
    lastAttemptAt,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_event_id')) {
      context.handle(
        _clientEventIdMeta,
        clientEventId.isAcceptableOrUnknown(
          data['client_event_id']!,
          _clientEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEventIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientEventId};
  @override
  SyncOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntry(
      clientEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_event_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_attempt_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntry extends DataClass implements Insertable<SyncOutboxEntry> {
  final String clientEventId;
  final String eventType;
  final String targetTable;
  final String targetId;
  final String payloadJson;
  final int retryCount;
  final String status;
  final String createdAt;
  final String? lastAttemptAt;
  final String? errorMessage;
  const SyncOutboxEntry({
    required this.clientEventId,
    required this.eventType,
    required this.targetTable,
    required this.targetId,
    required this.payloadJson,
    required this.retryCount,
    required this.status,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_event_id'] = Variable<String>(clientEventId);
    map['event_type'] = Variable<String>(eventType);
    map['target_table'] = Variable<String>(targetTable);
    map['target_id'] = Variable<String>(targetId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      clientEventId: Value(clientEventId),
      eventType: Value(eventType),
      targetTable: Value(targetTable),
      targetId: Value(targetId),
      payloadJson: Value(payloadJson),
      retryCount: Value(retryCount),
      status: Value(status),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntry(
      clientEventId: serializer.fromJson<String>(json['clientEventId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      targetId: serializer.fromJson<String>(json['targetId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<String?>(json['lastAttemptAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientEventId': serializer.toJson<String>(clientEventId),
      'eventType': serializer.toJson<String>(eventType),
      'targetTable': serializer.toJson<String>(targetTable),
      'targetId': serializer.toJson<String>(targetId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'lastAttemptAt': serializer.toJson<String?>(lastAttemptAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncOutboxEntry copyWith({
    String? clientEventId,
    String? eventType,
    String? targetTable,
    String? targetId,
    String? payloadJson,
    int? retryCount,
    String? status,
    String? createdAt,
    Value<String?> lastAttemptAt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncOutboxEntry(
    clientEventId: clientEventId ?? this.clientEventId,
    eventType: eventType ?? this.eventType,
    targetTable: targetTable ?? this.targetTable,
    targetId: targetId ?? this.targetId,
    payloadJson: payloadJson ?? this.payloadJson,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncOutboxEntry copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxEntry(
      clientEventId: data.clientEventId.present
          ? data.clientEventId.value
          : this.clientEventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntry(')
          ..write('clientEventId: $clientEventId, ')
          ..write('eventType: $eventType, ')
          ..write('targetTable: $targetTable, ')
          ..write('targetId: $targetId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientEventId,
    eventType,
    targetTable,
    targetId,
    payloadJson,
    retryCount,
    status,
    createdAt,
    lastAttemptAt,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntry &&
          other.clientEventId == this.clientEventId &&
          other.eventType == this.eventType &&
          other.targetTable == this.targetTable &&
          other.targetId == this.targetId &&
          other.payloadJson == this.payloadJson &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.errorMessage == this.errorMessage);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxEntry> {
  final Value<String> clientEventId;
  final Value<String> eventType;
  final Value<String> targetTable;
  final Value<String> targetId;
  final Value<String> payloadJson;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String?> lastAttemptAt;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.clientEventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.targetId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String clientEventId,
    required String eventType,
    required String targetTable,
    required String targetId,
    required String payloadJson,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientEventId = Value(clientEventId),
       eventType = Value(eventType),
       targetTable = Value(targetTable),
       targetId = Value(targetId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxEntry> custom({
    Expression<String>? clientEventId,
    Expression<String>? eventType,
    Expression<String>? targetTable,
    Expression<String>? targetId,
    Expression<String>? payloadJson,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? lastAttemptAt,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientEventId != null) 'client_event_id': clientEventId,
      if (eventType != null) 'event_type': eventType,
      if (targetTable != null) 'target_table': targetTable,
      if (targetId != null) 'target_id': targetId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? clientEventId,
    Value<String>? eventType,
    Value<String>? targetTable,
    Value<String>? targetId,
    Value<String>? payloadJson,
    Value<int>? retryCount,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String?>? lastAttemptAt,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      clientEventId: clientEventId ?? this.clientEventId,
      eventType: eventType ?? this.eventType,
      targetTable: targetTable ?? this.targetTable,
      targetId: targetId ?? this.targetId,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientEventId.present) {
      map['client_event_id'] = Variable<String>(clientEventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('clientEventId: $clientEventId, ')
          ..write('eventType: $eventType, ')
          ..write('targetTable: $targetTable, ')
          ..write('targetId: $targetId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoanApplicationsTable extends LoanApplications
    with TableInfo<$LoanApplicationsTable, LoanApplication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoanApplicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerIdMeta = const VerificationMeta(
    'partnerId',
  );
  @override
  late final GeneratedColumn<String> partnerId = GeneratedColumn<String>(
    'partner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedAmountMeta = const VerificationMeta(
    'requestedAmount',
  );
  @override
  late final GeneratedColumn<int> requestedAmount = GeneratedColumn<int>(
    'requested_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMonthsMeta = const VerificationMeta(
    'durationMonths',
  );
  @override
  late final GeneratedColumn<int> durationMonths = GeneratedColumn<int>(
    'duration_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyPaymentEstimateMeta =
      const VerificationMeta('monthlyPaymentEstimate');
  @override
  late final GeneratedColumn<int> monthlyPaymentEstimate = GeneratedColumn<int>(
    'monthly_payment_estimate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _passportScoreAtSubmissionMeta =
      const VerificationMeta('passportScoreAtSubmission');
  @override
  late final GeneratedColumn<int> passportScoreAtSubmission =
      GeneratedColumn<int>(
        'passport_score_at_submission',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _submissionDateMeta = const VerificationMeta(
    'submissionDate',
  );
  @override
  late final GeneratedColumn<String> submissionDate = GeneratedColumn<String>(
    'submission_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionNotesMeta = const VerificationMeta(
    'decisionNotes',
  );
  @override
  late final GeneratedColumn<String> decisionNotes = GeneratedColumn<String>(
    'decision_notes',
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
    shopId,
    partnerId,
    partnerName,
    requestedAmount,
    durationMonths,
    monthlyPaymentEstimate,
    purpose,
    status,
    passportScoreAtSubmission,
    submissionDate,
    decisionNotes,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loan_applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanApplication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('partner_id')) {
      context.handle(
        _partnerIdMeta,
        partnerId.isAcceptableOrUnknown(data['partner_id']!, _partnerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partnerIdMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partnerNameMeta);
    }
    if (data.containsKey('requested_amount')) {
      context.handle(
        _requestedAmountMeta,
        requestedAmount.isAcceptableOrUnknown(
          data['requested_amount']!,
          _requestedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedAmountMeta);
    }
    if (data.containsKey('duration_months')) {
      context.handle(
        _durationMonthsMeta,
        durationMonths.isAcceptableOrUnknown(
          data['duration_months']!,
          _durationMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMonthsMeta);
    }
    if (data.containsKey('monthly_payment_estimate')) {
      context.handle(
        _monthlyPaymentEstimateMeta,
        monthlyPaymentEstimate.isAcceptableOrUnknown(
          data['monthly_payment_estimate']!,
          _monthlyPaymentEstimateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyPaymentEstimateMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('passport_score_at_submission')) {
      context.handle(
        _passportScoreAtSubmissionMeta,
        passportScoreAtSubmission.isAcceptableOrUnknown(
          data['passport_score_at_submission']!,
          _passportScoreAtSubmissionMeta,
        ),
      );
    }
    if (data.containsKey('submission_date')) {
      context.handle(
        _submissionDateMeta,
        submissionDate.isAcceptableOrUnknown(
          data['submission_date']!,
          _submissionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submissionDateMeta);
    }
    if (data.containsKey('decision_notes')) {
      context.handle(
        _decisionNotesMeta,
        decisionNotes.isAcceptableOrUnknown(
          data['decision_notes']!,
          _decisionNotesMeta,
        ),
      );
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
  LoanApplication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanApplication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_id'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      requestedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_amount'],
      )!,
      durationMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_months'],
      )!,
      monthlyPaymentEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_payment_estimate'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      passportScoreAtSubmission: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passport_score_at_submission'],
      )!,
      submissionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submission_date'],
      )!,
      decisionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_notes'],
      ),
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
  $LoanApplicationsTable createAlias(String alias) {
    return $LoanApplicationsTable(attachedDatabase, alias);
  }
}

class LoanApplication extends DataClass implements Insertable<LoanApplication> {
  final String id;
  final String shopId;
  final String partnerId;
  final String partnerName;
  final int requestedAmount;
  final int durationMonths;
  final int monthlyPaymentEstimate;
  final String purpose;
  final String status;
  final int passportScoreAtSubmission;
  final String submissionDate;
  final String? decisionNotes;
  final String syncStatus;
  final String createdAt;
  const LoanApplication({
    required this.id,
    required this.shopId,
    required this.partnerId,
    required this.partnerName,
    required this.requestedAmount,
    required this.durationMonths,
    required this.monthlyPaymentEstimate,
    required this.purpose,
    required this.status,
    required this.passportScoreAtSubmission,
    required this.submissionDate,
    this.decisionNotes,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['partner_id'] = Variable<String>(partnerId);
    map['partner_name'] = Variable<String>(partnerName);
    map['requested_amount'] = Variable<int>(requestedAmount);
    map['duration_months'] = Variable<int>(durationMonths);
    map['monthly_payment_estimate'] = Variable<int>(monthlyPaymentEstimate);
    map['purpose'] = Variable<String>(purpose);
    map['status'] = Variable<String>(status);
    map['passport_score_at_submission'] = Variable<int>(
      passportScoreAtSubmission,
    );
    map['submission_date'] = Variable<String>(submissionDate);
    if (!nullToAbsent || decisionNotes != null) {
      map['decision_notes'] = Variable<String>(decisionNotes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LoanApplicationsCompanion toCompanion(bool nullToAbsent) {
    return LoanApplicationsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partnerId: Value(partnerId),
      partnerName: Value(partnerName),
      requestedAmount: Value(requestedAmount),
      durationMonths: Value(durationMonths),
      monthlyPaymentEstimate: Value(monthlyPaymentEstimate),
      purpose: Value(purpose),
      status: Value(status),
      passportScoreAtSubmission: Value(passportScoreAtSubmission),
      submissionDate: Value(submissionDate),
      decisionNotes: decisionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionNotes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LoanApplication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanApplication(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      partnerId: serializer.fromJson<String>(json['partnerId']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      requestedAmount: serializer.fromJson<int>(json['requestedAmount']),
      durationMonths: serializer.fromJson<int>(json['durationMonths']),
      monthlyPaymentEstimate: serializer.fromJson<int>(
        json['monthlyPaymentEstimate'],
      ),
      purpose: serializer.fromJson<String>(json['purpose']),
      status: serializer.fromJson<String>(json['status']),
      passportScoreAtSubmission: serializer.fromJson<int>(
        json['passportScoreAtSubmission'],
      ),
      submissionDate: serializer.fromJson<String>(json['submissionDate']),
      decisionNotes: serializer.fromJson<String?>(json['decisionNotes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'partnerId': serializer.toJson<String>(partnerId),
      'partnerName': serializer.toJson<String>(partnerName),
      'requestedAmount': serializer.toJson<int>(requestedAmount),
      'durationMonths': serializer.toJson<int>(durationMonths),
      'monthlyPaymentEstimate': serializer.toJson<int>(monthlyPaymentEstimate),
      'purpose': serializer.toJson<String>(purpose),
      'status': serializer.toJson<String>(status),
      'passportScoreAtSubmission': serializer.toJson<int>(
        passportScoreAtSubmission,
      ),
      'submissionDate': serializer.toJson<String>(submissionDate),
      'decisionNotes': serializer.toJson<String?>(decisionNotes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  LoanApplication copyWith({
    String? id,
    String? shopId,
    String? partnerId,
    String? partnerName,
    int? requestedAmount,
    int? durationMonths,
    int? monthlyPaymentEstimate,
    String? purpose,
    String? status,
    int? passportScoreAtSubmission,
    String? submissionDate,
    Value<String?> decisionNotes = const Value.absent(),
    String? syncStatus,
    String? createdAt,
  }) => LoanApplication(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partnerId: partnerId ?? this.partnerId,
    partnerName: partnerName ?? this.partnerName,
    requestedAmount: requestedAmount ?? this.requestedAmount,
    durationMonths: durationMonths ?? this.durationMonths,
    monthlyPaymentEstimate:
        monthlyPaymentEstimate ?? this.monthlyPaymentEstimate,
    purpose: purpose ?? this.purpose,
    status: status ?? this.status,
    passportScoreAtSubmission:
        passportScoreAtSubmission ?? this.passportScoreAtSubmission,
    submissionDate: submissionDate ?? this.submissionDate,
    decisionNotes: decisionNotes.present
        ? decisionNotes.value
        : this.decisionNotes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LoanApplication copyWithCompanion(LoanApplicationsCompanion data) {
    return LoanApplication(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partnerId: data.partnerId.present ? data.partnerId.value : this.partnerId,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      requestedAmount: data.requestedAmount.present
          ? data.requestedAmount.value
          : this.requestedAmount,
      durationMonths: data.durationMonths.present
          ? data.durationMonths.value
          : this.durationMonths,
      monthlyPaymentEstimate: data.monthlyPaymentEstimate.present
          ? data.monthlyPaymentEstimate.value
          : this.monthlyPaymentEstimate,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      status: data.status.present ? data.status.value : this.status,
      passportScoreAtSubmission: data.passportScoreAtSubmission.present
          ? data.passportScoreAtSubmission.value
          : this.passportScoreAtSubmission,
      submissionDate: data.submissionDate.present
          ? data.submissionDate.value
          : this.submissionDate,
      decisionNotes: data.decisionNotes.present
          ? data.decisionNotes.value
          : this.decisionNotes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanApplication(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('requestedAmount: $requestedAmount, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('monthlyPaymentEstimate: $monthlyPaymentEstimate, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status, ')
          ..write('passportScoreAtSubmission: $passportScoreAtSubmission, ')
          ..write('submissionDate: $submissionDate, ')
          ..write('decisionNotes: $decisionNotes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    partnerId,
    partnerName,
    requestedAmount,
    durationMonths,
    monthlyPaymentEstimate,
    purpose,
    status,
    passportScoreAtSubmission,
    submissionDate,
    decisionNotes,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanApplication &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partnerId == this.partnerId &&
          other.partnerName == this.partnerName &&
          other.requestedAmount == this.requestedAmount &&
          other.durationMonths == this.durationMonths &&
          other.monthlyPaymentEstimate == this.monthlyPaymentEstimate &&
          other.purpose == this.purpose &&
          other.status == this.status &&
          other.passportScoreAtSubmission == this.passportScoreAtSubmission &&
          other.submissionDate == this.submissionDate &&
          other.decisionNotes == this.decisionNotes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LoanApplicationsCompanion extends UpdateCompanion<LoanApplication> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> partnerId;
  final Value<String> partnerName;
  final Value<int> requestedAmount;
  final Value<int> durationMonths;
  final Value<int> monthlyPaymentEstimate;
  final Value<String> purpose;
  final Value<String> status;
  final Value<int> passportScoreAtSubmission;
  final Value<String> submissionDate;
  final Value<String?> decisionNotes;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LoanApplicationsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partnerId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.requestedAmount = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.monthlyPaymentEstimate = const Value.absent(),
    this.purpose = const Value.absent(),
    this.status = const Value.absent(),
    this.passportScoreAtSubmission = const Value.absent(),
    this.submissionDate = const Value.absent(),
    this.decisionNotes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoanApplicationsCompanion.insert({
    required String id,
    required String shopId,
    required String partnerId,
    required String partnerName,
    required int requestedAmount,
    required int durationMonths,
    required int monthlyPaymentEstimate,
    required String purpose,
    this.status = const Value.absent(),
    this.passportScoreAtSubmission = const Value.absent(),
    required String submissionDate,
    this.decisionNotes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       partnerId = Value(partnerId),
       partnerName = Value(partnerName),
       requestedAmount = Value(requestedAmount),
       durationMonths = Value(durationMonths),
       monthlyPaymentEstimate = Value(monthlyPaymentEstimate),
       purpose = Value(purpose),
       submissionDate = Value(submissionDate),
       createdAt = Value(createdAt);
  static Insertable<LoanApplication> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partnerId,
    Expression<String>? partnerName,
    Expression<int>? requestedAmount,
    Expression<int>? durationMonths,
    Expression<int>? monthlyPaymentEstimate,
    Expression<String>? purpose,
    Expression<String>? status,
    Expression<int>? passportScoreAtSubmission,
    Expression<String>? submissionDate,
    Expression<String>? decisionNotes,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partnerId != null) 'partner_id': partnerId,
      if (partnerName != null) 'partner_name': partnerName,
      if (requestedAmount != null) 'requested_amount': requestedAmount,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (monthlyPaymentEstimate != null)
        'monthly_payment_estimate': monthlyPaymentEstimate,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (passportScoreAtSubmission != null)
        'passport_score_at_submission': passportScoreAtSubmission,
      if (submissionDate != null) 'submission_date': submissionDate,
      if (decisionNotes != null) 'decision_notes': decisionNotes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoanApplicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? partnerId,
    Value<String>? partnerName,
    Value<int>? requestedAmount,
    Value<int>? durationMonths,
    Value<int>? monthlyPaymentEstimate,
    Value<String>? purpose,
    Value<String>? status,
    Value<int>? passportScoreAtSubmission,
    Value<String>? submissionDate,
    Value<String?>? decisionNotes,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return LoanApplicationsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      monthlyPaymentEstimate:
          monthlyPaymentEstimate ?? this.monthlyPaymentEstimate,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      passportScoreAtSubmission:
          passportScoreAtSubmission ?? this.passportScoreAtSubmission,
      submissionDate: submissionDate ?? this.submissionDate,
      decisionNotes: decisionNotes ?? this.decisionNotes,
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
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partnerId.present) {
      map['partner_id'] = Variable<String>(partnerId.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (requestedAmount.present) {
      map['requested_amount'] = Variable<int>(requestedAmount.value);
    }
    if (durationMonths.present) {
      map['duration_months'] = Variable<int>(durationMonths.value);
    }
    if (monthlyPaymentEstimate.present) {
      map['monthly_payment_estimate'] = Variable<int>(
        monthlyPaymentEstimate.value,
      );
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (passportScoreAtSubmission.present) {
      map['passport_score_at_submission'] = Variable<int>(
        passportScoreAtSubmission.value,
      );
    }
    if (submissionDate.present) {
      map['submission_date'] = Variable<String>(submissionDate.value);
    }
    if (decisionNotes.present) {
      map['decision_notes'] = Variable<String>(decisionNotes.value);
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
    return (StringBuffer('LoanApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('requestedAmount: $requestedAmount, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('monthlyPaymentEstimate: $monthlyPaymentEstimate, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status, ')
          ..write('passportScoreAtSubmission: $passportScoreAtSubmission, ')
          ..write('submissionDate: $submissionDate, ')
          ..write('decisionNotes: $decisionNotes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
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
  late final $DailyClosuresTable dailyClosures = $DailyClosuresTable(this);
  late final $DebtorsTable debtors = $DebtorsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $DebtPaymentsTable debtPayments = $DebtPaymentsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $LoanApplicationsTable loanApplications = $LoanApplicationsTable(
    this,
  );
  late final Index salesClosureIdIdx = Index(
    'sales_closure_id_idx',
    'CREATE INDEX sales_closure_id_idx ON sales (closure_id)',
  );
  late final Index salesSyncStatusIdx = Index(
    'sales_sync_status_idx',
    'CREATE INDEX sales_sync_status_idx ON sales (sync_status)',
  );
  late final Index dailyClosuresDateIdx = Index(
    'daily_closures_date_idx',
    'CREATE INDEX daily_closures_date_idx ON daily_closures (closure_date)',
  );
  late final Index dailyClosuresSyncStatusIdx = Index(
    'daily_closures_sync_status_idx',
    'CREATE INDEX daily_closures_sync_status_idx ON daily_closures (sync_status)',
  );
  late final Index debtorsSyncStatusIdx = Index(
    'debtors_sync_status_idx',
    'CREATE INDEX debtors_sync_status_idx ON debtors (sync_status)',
  );
  late final Index debtsDebtorIdIdx = Index(
    'debts_debtor_id_idx',
    'CREATE INDEX debts_debtor_id_idx ON debts (debtor_id)',
  );
  late final Index debtsStatusIdx = Index(
    'debts_status_idx',
    'CREATE INDEX debts_status_idx ON debts (status)',
  );
  late final Index debtsSyncStatusIdx = Index(
    'debts_sync_status_idx',
    'CREATE INDEX debts_sync_status_idx ON debts (sync_status)',
  );
  late final Index debtPaymentsDebtIdIdx = Index(
    'debt_payments_debt_id_idx',
    'CREATE INDEX debt_payments_debt_id_idx ON debt_payments (debt_id)',
  );
  late final Index debtPaymentsPaymentMethodIdx = Index(
    'debt_payments_payment_method_idx',
    'CREATE INDEX debt_payments_payment_method_idx ON debt_payments (payment_method)',
  );
  late final Index debtPaymentsSyncStatusIdx = Index(
    'debt_payments_sync_status_idx',
    'CREATE INDEX debt_payments_sync_status_idx ON debt_payments (sync_status)',
  );
  late final Index debtPaymentsClosureIdIdx = Index(
    'debt_payments_closure_id_idx',
    'CREATE INDEX debt_payments_closure_id_idx ON debt_payments (closure_id)',
  );
  late final Index syncOutboxStatusIdx = Index(
    'sync_outbox_status_idx',
    'CREATE INDEX sync_outbox_status_idx ON sync_outbox (status)',
  );
  late final Index syncOutboxCreatedAtIdx = Index(
    'sync_outbox_created_at_idx',
    'CREATE INDEX sync_outbox_created_at_idx ON sync_outbox (created_at)',
  );
  late final Index loanApplicationsShopIdx = Index(
    'loan_applications_shop_idx',
    'CREATE INDEX loan_applications_shop_idx ON loan_applications (shop_id)',
  );
  late final Index loanApplicationsStatusIdx = Index(
    'loan_applications_status_idx',
    'CREATE INDEX loan_applications_status_idx ON loan_applications (status)',
  );
  late final Index loanApplicationsSyncIdx = Index(
    'loan_applications_sync_idx',
    'CREATE INDEX loan_applications_sync_idx ON loan_applications (sync_status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shops,
    sales,
    dailyClosures,
    debtors,
    debts,
    debtPayments,
    syncOutbox,
    loanApplications,
    salesClosureIdIdx,
    salesSyncStatusIdx,
    dailyClosuresDateIdx,
    dailyClosuresSyncStatusIdx,
    debtorsSyncStatusIdx,
    debtsDebtorIdIdx,
    debtsStatusIdx,
    debtsSyncStatusIdx,
    debtPaymentsDebtIdIdx,
    debtPaymentsPaymentMethodIdx,
    debtPaymentsSyncStatusIdx,
    debtPaymentsClosureIdIdx,
    syncOutboxStatusIdx,
    syncOutboxCreatedAtIdx,
    loanApplicationsShopIdx,
    loanApplicationsStatusIdx,
    loanApplicationsSyncIdx,
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
typedef $$DailyClosuresTableCreateCompanionBuilder =
    DailyClosuresCompanion Function({
      required String id,
      required String shopId,
      required String closureDate,
      required String cutoffTimestamp,
      required int totalSalesAmount,
      Value<int> totalCashDebtInflow,
      Value<int> totalCreditSalesAmount,
      Value<int> totalExpensesAmount,
      Value<int> cashCounted,
      Value<double?> gpsLatitude,
      Value<double?> gpsLongitude,
      Value<double?> distanceMeters,
      Value<bool> isFlaggedLocation,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$DailyClosuresTableUpdateCompanionBuilder =
    DailyClosuresCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> closureDate,
      Value<String> cutoffTimestamp,
      Value<int> totalSalesAmount,
      Value<int> totalCashDebtInflow,
      Value<int> totalCreditSalesAmount,
      Value<int> totalExpensesAmount,
      Value<int> cashCounted,
      Value<double?> gpsLatitude,
      Value<double?> gpsLongitude,
      Value<double?> distanceMeters,
      Value<bool> isFlaggedLocation,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$DailyClosuresTableReferences
    extends BaseReferences<_$AppDatabase, $DailyClosuresTable, DailyClosure> {
  $$DailyClosuresTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DebtPaymentsTable, List<DebtPayment>>
  _debtPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debtPayments,
    aliasName: 'daily_closures__id__debt_payments__closure_id',
  );

  $$DebtPaymentsTableProcessedTableManager get debtPaymentsRefs {
    final manager = $$DebtPaymentsTableTableManager(
      $_db,
      $_db.debtPayments,
    ).filter((f) => f.closureId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailyClosuresTableFilterComposer
    extends Composer<_$AppDatabase, $DailyClosuresTable> {
  $$DailyClosuresTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closureDate => $composableBuilder(
    column: $table.closureDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cutoffTimestamp => $composableBuilder(
    column: $table.cutoffTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSalesAmount => $composableBuilder(
    column: $table.totalSalesAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCashDebtInflow => $composableBuilder(
    column: $table.totalCashDebtInflow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCreditSalesAmount => $composableBuilder(
    column: $table.totalCreditSalesAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpensesAmount => $composableBuilder(
    column: $table.totalExpensesAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashCounted => $composableBuilder(
    column: $table.cashCounted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLatitude => $composableBuilder(
    column: $table.gpsLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLongitude => $composableBuilder(
    column: $table.gpsLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFlaggedLocation => $composableBuilder(
    column: $table.isFlaggedLocation,
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> debtPaymentsRefs(
    Expression<bool> Function($$DebtPaymentsTableFilterComposer f) f,
  ) {
    final $$DebtPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.closureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyClosuresTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyClosuresTable> {
  $$DailyClosuresTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closureDate => $composableBuilder(
    column: $table.closureDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cutoffTimestamp => $composableBuilder(
    column: $table.cutoffTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSalesAmount => $composableBuilder(
    column: $table.totalSalesAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCashDebtInflow => $composableBuilder(
    column: $table.totalCashDebtInflow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCreditSalesAmount => $composableBuilder(
    column: $table.totalCreditSalesAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpensesAmount => $composableBuilder(
    column: $table.totalExpensesAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashCounted => $composableBuilder(
    column: $table.cashCounted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLatitude => $composableBuilder(
    column: $table.gpsLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLongitude => $composableBuilder(
    column: $table.gpsLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFlaggedLocation => $composableBuilder(
    column: $table.isFlaggedLocation,
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyClosuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyClosuresTable> {
  $$DailyClosuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get closureDate => $composableBuilder(
    column: $table.closureDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cutoffTimestamp => $composableBuilder(
    column: $table.cutoffTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSalesAmount => $composableBuilder(
    column: $table.totalSalesAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCashDebtInflow => $composableBuilder(
    column: $table.totalCashDebtInflow,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCreditSalesAmount => $composableBuilder(
    column: $table.totalCreditSalesAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalExpensesAmount => $composableBuilder(
    column: $table.totalExpensesAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cashCounted => $composableBuilder(
    column: $table.cashCounted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsLatitude => $composableBuilder(
    column: $table.gpsLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsLongitude => $composableBuilder(
    column: $table.gpsLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFlaggedLocation => $composableBuilder(
    column: $table.isFlaggedLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> debtPaymentsRefs<T extends Object>(
    Expression<T> Function($$DebtPaymentsTableAnnotationComposer a) f,
  ) {
    final $$DebtPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.closureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyClosuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyClosuresTable,
          DailyClosure,
          $$DailyClosuresTableFilterComposer,
          $$DailyClosuresTableOrderingComposer,
          $$DailyClosuresTableAnnotationComposer,
          $$DailyClosuresTableCreateCompanionBuilder,
          $$DailyClosuresTableUpdateCompanionBuilder,
          (DailyClosure, $$DailyClosuresTableReferences),
          DailyClosure,
          PrefetchHooks Function({bool debtPaymentsRefs})
        > {
  $$DailyClosuresTableTableManager(_$AppDatabase db, $DailyClosuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClosuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClosuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyClosuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> closureDate = const Value.absent(),
                Value<String> cutoffTimestamp = const Value.absent(),
                Value<int> totalSalesAmount = const Value.absent(),
                Value<int> totalCashDebtInflow = const Value.absent(),
                Value<int> totalCreditSalesAmount = const Value.absent(),
                Value<int> totalExpensesAmount = const Value.absent(),
                Value<int> cashCounted = const Value.absent(),
                Value<double?> gpsLatitude = const Value.absent(),
                Value<double?> gpsLongitude = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<bool> isFlaggedLocation = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosuresCompanion(
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
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String closureDate,
                required String cutoffTimestamp,
                required int totalSalesAmount,
                Value<int> totalCashDebtInflow = const Value.absent(),
                Value<int> totalCreditSalesAmount = const Value.absent(),
                Value<int> totalExpensesAmount = const Value.absent(),
                Value<int> cashCounted = const Value.absent(),
                Value<double?> gpsLatitude = const Value.absent(),
                Value<double?> gpsLongitude = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<bool> isFlaggedLocation = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyClosuresCompanion.insert(
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
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyClosuresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (debtPaymentsRefs) db.debtPayments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtPaymentsRefs)
                    await $_getPrefetchedData<
                      DailyClosure,
                      $DailyClosuresTable,
                      DebtPayment
                    >(
                      currentTable: table,
                      referencedTable: $$DailyClosuresTableReferences
                          ._debtPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DailyClosuresTableReferences(
                            db,
                            table,
                            p0,
                          ).debtPaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.closureId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DailyClosuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyClosuresTable,
      DailyClosure,
      $$DailyClosuresTableFilterComposer,
      $$DailyClosuresTableOrderingComposer,
      $$DailyClosuresTableAnnotationComposer,
      $$DailyClosuresTableCreateCompanionBuilder,
      $$DailyClosuresTableUpdateCompanionBuilder,
      (DailyClosure, $$DailyClosuresTableReferences),
      DailyClosure,
      PrefetchHooks Function({bool debtPaymentsRefs})
    >;
typedef $$DebtorsTableCreateCompanionBuilder =
    DebtorsCompanion Function({
      required String id,
      required String name,
      Value<String?> phoneNumber,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$DebtorsTableUpdateCompanionBuilder =
    DebtorsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> phoneNumber,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$DebtorsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtorsTable, Debtor> {
  $$DebtorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DebtsTable, List<Debt>> _debtsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.debts,
    aliasName: 'debtors__id__debts__debtor_id',
  );

  $$DebtsTableProcessedTableManager get debtsRefs {
    final manager = $$DebtsTableTableManager(
      $_db,
      $_db.debts,
    ).filter((f) => f.debtorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtorsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtorsTable> {
  $$DebtorsTableFilterComposer({
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

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
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

  Expression<bool> debtsRefs(
    Expression<bool> Function($$DebtsTableFilterComposer f) f,
  ) {
    final $$DebtsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.debtorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableFilterComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtorsTable> {
  $$DebtorsTableOrderingComposer({
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

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
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

class $$DebtorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtorsTable> {
  $$DebtorsTableAnnotationComposer({
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

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> debtsRefs<T extends Object>(
    Expression<T> Function($$DebtsTableAnnotationComposer a) f,
  ) {
    final $$DebtsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.debtorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableAnnotationComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtorsTable,
          Debtor,
          $$DebtorsTableFilterComposer,
          $$DebtorsTableOrderingComposer,
          $$DebtorsTableAnnotationComposer,
          $$DebtorsTableCreateCompanionBuilder,
          $$DebtorsTableUpdateCompanionBuilder,
          (Debtor, $$DebtorsTableReferences),
          Debtor,
          PrefetchHooks Function({bool debtsRefs})
        > {
  $$DebtorsTableTableManager(_$AppDatabase db, $DebtorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtorsCompanion(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phoneNumber = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DebtorsCompanion.insert(
                id: id,
                name: name,
                phoneNumber: phoneNumber,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DebtorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (debtsRefs) db.debts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtsRefs)
                    await $_getPrefetchedData<Debtor, $DebtorsTable, Debt>(
                      currentTable: table,
                      referencedTable: $$DebtorsTableReferences._debtsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$DebtorsTableReferences(db, table, p0).debtsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.debtorId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DebtorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtorsTable,
      Debtor,
      $$DebtorsTableFilterComposer,
      $$DebtorsTableOrderingComposer,
      $$DebtorsTableAnnotationComposer,
      $$DebtorsTableCreateCompanionBuilder,
      $$DebtorsTableUpdateCompanionBuilder,
      (Debtor, $$DebtorsTableReferences),
      Debtor,
      PrefetchHooks Function({bool debtsRefs})
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      required String id,
      required String debtorId,
      required int initialAmount,
      required int remainingAmount,
      required String dueDate,
      Value<String> status,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<String> id,
      Value<String> debtorId,
      Value<int> initialAmount,
      Value<int> remainingAmount,
      Value<String> dueDate,
      Value<String> status,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$DebtsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTable, Debt> {
  $$DebtsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DebtorsTable _debtorIdTable(_$AppDatabase db) =>
      db.debtors.createAlias('debts__debtor_id__debtors__id');

  $$DebtorsTableProcessedTableManager get debtorId {
    final $_column = $_itemColumn<String>('debtor_id')!;

    final manager = $$DebtorsTableTableManager(
      $_db,
      $_db.debtors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DebtPaymentsTable, List<DebtPayment>>
  _debtPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debtPayments,
    aliasName: 'debts__id__debt_payments__debt_id',
  );

  $$DebtPaymentsTableProcessedTableManager get debtPaymentsRefs {
    final manager = $$DebtPaymentsTableTableManager(
      $_db,
      $_db.debtPayments,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
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

  ColumnFilters<int> get initialAmount => $composableBuilder(
    column: $table.initialAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtorsTableFilterComposer get debtorId {
    final $$DebtorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableFilterComposer(
            $db: $db,
            $table: $db.debtors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> debtPaymentsRefs(
    Expression<bool> Function($$DebtPaymentsTableFilterComposer f) f,
  ) {
    final $$DebtPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
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

  ColumnOrderings<int> get initialAmount => $composableBuilder(
    column: $table.initialAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtorsTableOrderingComposer get debtorId {
    final $$DebtorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableOrderingComposer(
            $db: $db,
            $table: $db.debtors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get initialAmount => $composableBuilder(
    column: $table.initialAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DebtorsTableAnnotationComposer get debtorId {
    final $$DebtorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtorId,
      referencedTable: $db.debtors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtorsTableAnnotationComposer(
            $db: $db,
            $table: $db.debtors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> debtPaymentsRefs<T extends Object>(
    Expression<T> Function($$DebtPaymentsTableAnnotationComposer a) f,
  ) {
    final $$DebtPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, $$DebtsTableReferences),
          Debt,
          PrefetchHooks Function({bool debtorId, bool debtPaymentsRefs})
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtorId = const Value.absent(),
                Value<int> initialAmount = const Value.absent(),
                Value<int> remainingAmount = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                debtorId: debtorId,
                initialAmount: initialAmount,
                remainingAmount: remainingAmount,
                dueDate: dueDate,
                status: status,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtorId,
                required int initialAmount,
                required int remainingAmount,
                required String dueDate,
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                debtorId: debtorId,
                initialAmount: initialAmount,
                remainingAmount: remainingAmount,
                dueDate: dueDate,
                status: status,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DebtsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({debtorId = false, debtPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (debtPaymentsRefs) db.debtPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (debtorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.debtorId,
                                    referencedTable: $$DebtsTableReferences
                                        ._debtorIdTable(db),
                                    referencedColumn: $$DebtsTableReferences
                                        ._debtorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (debtPaymentsRefs)
                        await $_getPrefetchedData<
                          Debt,
                          $DebtsTable,
                          DebtPayment
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableReferences
                              ._debtPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableReferences(
                                db,
                                table,
                                p0,
                              ).debtPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, $$DebtsTableReferences),
      Debt,
      PrefetchHooks Function({bool debtorId, bool debtPaymentsRefs})
    >;
typedef $$DebtPaymentsTableCreateCompanionBuilder =
    DebtPaymentsCompanion Function({
      required String id,
      required String debtId,
      required int paymentAmount,
      Value<String> paymentMethod,
      Value<String?> closureId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      required String paidAt,
      Value<int> rowid,
    });
typedef $$DebtPaymentsTableUpdateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<String> id,
      Value<String> debtId,
      Value<int> paymentAmount,
      Value<String> paymentMethod,
      Value<String?> closureId,
      Value<String> syncStatus,
      Value<String?> lastSyncedAt,
      Value<String> paidAt,
      Value<int> rowid,
    });

final class $$DebtPaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment> {
  $$DebtPaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DebtsTable _debtIdTable(_$AppDatabase db) =>
      db.debts.createAlias('debt_payments__debt_id__debts__id');

  $$DebtsTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableManager(
      $_db,
      $_db.debts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DailyClosuresTable _closureIdTable(_$AppDatabase db) => db
      .dailyClosures
      .createAlias('debt_payments__closure_id__daily_closures__id');

  $$DailyClosuresTableProcessedTableManager? get closureId {
    final $_column = $_itemColumn<String>('closure_id');
    if ($_column == null) return null;
    final manager = $$DailyClosuresTableTableManager(
      $_db,
      $_db.dailyClosures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_closureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableFilterComposer({
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

  ColumnFilters<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
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

  ColumnFilters<String> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtsTableFilterComposer get debtId {
    final $$DebtsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableFilterComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DailyClosuresTableFilterComposer get closureId {
    final $$DailyClosuresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closureId,
      referencedTable: $db.dailyClosures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyClosuresTableFilterComposer(
            $db: $db,
            $table: $db.dailyClosures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
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

  ColumnOrderings<String> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableOrderingComposer get debtId {
    final $$DebtsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableOrderingComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DailyClosuresTableOrderingComposer get closureId {
    final $$DailyClosuresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closureId,
      referencedTable: $db.dailyClosures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyClosuresTableOrderingComposer(
            $db: $db,
            $table: $db.dailyClosures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$DebtsTableAnnotationComposer get debtId {
    final $$DebtsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableAnnotationComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DailyClosuresTableAnnotationComposer get closureId {
    final $$DailyClosuresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closureId,
      referencedTable: $db.dailyClosures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyClosuresTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyClosures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtPaymentsTable,
          DebtPayment,
          $$DebtPaymentsTableFilterComposer,
          $$DebtPaymentsTableOrderingComposer,
          $$DebtPaymentsTableAnnotationComposer,
          $$DebtPaymentsTableCreateCompanionBuilder,
          $$DebtPaymentsTableUpdateCompanionBuilder,
          (DebtPayment, $$DebtPaymentsTableReferences),
          DebtPayment,
          PrefetchHooks Function({bool debtId, bool closureId})
        > {
  $$DebtPaymentsTableTableManager(_$AppDatabase db, $DebtPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<int> paymentAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> closureId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion(
                id: id,
                debtId: debtId,
                paymentAmount: paymentAmount,
                paymentMethod: paymentMethod,
                closureId: closureId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtId,
                required int paymentAmount,
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> closureId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                required String paidAt,
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion.insert(
                id: id,
                debtId: debtId,
                paymentAmount: paymentAmount,
                paymentMethod: paymentMethod,
                closureId: closureId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DebtPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false, closureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable: $$DebtPaymentsTableReferences
                                    ._debtIdTable(db),
                                referencedColumn: $$DebtPaymentsTableReferences
                                    ._debtIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (closureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.closureId,
                                referencedTable: $$DebtPaymentsTableReferences
                                    ._closureIdTable(db),
                                referencedColumn: $$DebtPaymentsTableReferences
                                    ._closureIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtPaymentsTable,
      DebtPayment,
      $$DebtPaymentsTableFilterComposer,
      $$DebtPaymentsTableOrderingComposer,
      $$DebtPaymentsTableAnnotationComposer,
      $$DebtPaymentsTableCreateCompanionBuilder,
      $$DebtPaymentsTableUpdateCompanionBuilder,
      (DebtPayment, $$DebtPaymentsTableReferences),
      DebtPayment,
      PrefetchHooks Function({bool debtId, bool closureId})
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String clientEventId,
      required String eventType,
      required String targetTable,
      required String targetId,
      required String payloadJson,
      Value<int> retryCount,
      Value<String> status,
      required String createdAt,
      Value<String?> lastAttemptAt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> clientEventId,
      Value<String> eventType,
      Value<String> targetTable,
      Value<String> targetId,
      Value<String> payloadJson,
      Value<int> retryCount,
      Value<String> status,
      Value<String> createdAt,
      Value<String?> lastAttemptAt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxEntry,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxEntry,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxEntry>,
          ),
          SyncOutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientEventId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                clientEventId: clientEventId,
                eventType: eventType,
                targetTable: targetTable,
                targetId: targetId,
                payloadJson: payloadJson,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientEventId,
                required String eventType,
                required String targetTable,
                required String targetId,
                required String payloadJson,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdAt,
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                clientEventId: clientEventId,
                eventType: eventType,
                targetTable: targetTable,
                targetId: targetId,
                payloadJson: payloadJson,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxEntry,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxEntry>,
      ),
      SyncOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$LoanApplicationsTableCreateCompanionBuilder =
    LoanApplicationsCompanion Function({
      required String id,
      required String shopId,
      required String partnerId,
      required String partnerName,
      required int requestedAmount,
      required int durationMonths,
      required int monthlyPaymentEstimate,
      required String purpose,
      Value<String> status,
      Value<int> passportScoreAtSubmission,
      required String submissionDate,
      Value<String?> decisionNotes,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$LoanApplicationsTableUpdateCompanionBuilder =
    LoanApplicationsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> partnerId,
      Value<String> partnerName,
      Value<int> requestedAmount,
      Value<int> durationMonths,
      Value<int> monthlyPaymentEstimate,
      Value<String> purpose,
      Value<String> status,
      Value<int> passportScoreAtSubmission,
      Value<String> submissionDate,
      Value<String?> decisionNotes,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$LoanApplicationsTableFilterComposer
    extends Composer<_$AppDatabase, $LoanApplicationsTable> {
  $$LoanApplicationsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedAmount => $composableBuilder(
    column: $table.requestedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyPaymentEstimate => $composableBuilder(
    column: $table.monthlyPaymentEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passportScoreAtSubmission => $composableBuilder(
    column: $table.passportScoreAtSubmission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionNotes => $composableBuilder(
    column: $table.decisionNotes,
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

class $$LoanApplicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoanApplicationsTable> {
  $$LoanApplicationsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedAmount => $composableBuilder(
    column: $table.requestedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyPaymentEstimate => $composableBuilder(
    column: $table.monthlyPaymentEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passportScoreAtSubmission => $composableBuilder(
    column: $table.passportScoreAtSubmission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionNotes => $composableBuilder(
    column: $table.decisionNotes,
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

class $$LoanApplicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoanApplicationsTable> {
  $$LoanApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get partnerId =>
      $composableBuilder(column: $table.partnerId, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedAmount => $composableBuilder(
    column: $table.requestedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyPaymentEstimate => $composableBuilder(
    column: $table.monthlyPaymentEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get passportScoreAtSubmission => $composableBuilder(
    column: $table.passportScoreAtSubmission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionNotes => $composableBuilder(
    column: $table.decisionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LoanApplicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoanApplicationsTable,
          LoanApplication,
          $$LoanApplicationsTableFilterComposer,
          $$LoanApplicationsTableOrderingComposer,
          $$LoanApplicationsTableAnnotationComposer,
          $$LoanApplicationsTableCreateCompanionBuilder,
          $$LoanApplicationsTableUpdateCompanionBuilder,
          (
            LoanApplication,
            BaseReferences<
              _$AppDatabase,
              $LoanApplicationsTable,
              LoanApplication
            >,
          ),
          LoanApplication,
          PrefetchHooks Function()
        > {
  $$LoanApplicationsTableTableManager(
    _$AppDatabase db,
    $LoanApplicationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoanApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoanApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoanApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> partnerId = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<int> requestedAmount = const Value.absent(),
                Value<int> durationMonths = const Value.absent(),
                Value<int> monthlyPaymentEstimate = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> passportScoreAtSubmission = const Value.absent(),
                Value<String> submissionDate = const Value.absent(),
                Value<String?> decisionNotes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoanApplicationsCompanion(
                id: id,
                shopId: shopId,
                partnerId: partnerId,
                partnerName: partnerName,
                requestedAmount: requestedAmount,
                durationMonths: durationMonths,
                monthlyPaymentEstimate: monthlyPaymentEstimate,
                purpose: purpose,
                status: status,
                passportScoreAtSubmission: passportScoreAtSubmission,
                submissionDate: submissionDate,
                decisionNotes: decisionNotes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String partnerId,
                required String partnerName,
                required int requestedAmount,
                required int durationMonths,
                required int monthlyPaymentEstimate,
                required String purpose,
                Value<String> status = const Value.absent(),
                Value<int> passportScoreAtSubmission = const Value.absent(),
                required String submissionDate,
                Value<String?> decisionNotes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LoanApplicationsCompanion.insert(
                id: id,
                shopId: shopId,
                partnerId: partnerId,
                partnerName: partnerName,
                requestedAmount: requestedAmount,
                durationMonths: durationMonths,
                monthlyPaymentEstimate: monthlyPaymentEstimate,
                purpose: purpose,
                status: status,
                passportScoreAtSubmission: passportScoreAtSubmission,
                submissionDate: submissionDate,
                decisionNotes: decisionNotes,
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

typedef $$LoanApplicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoanApplicationsTable,
      LoanApplication,
      $$LoanApplicationsTableFilterComposer,
      $$LoanApplicationsTableOrderingComposer,
      $$LoanApplicationsTableAnnotationComposer,
      $$LoanApplicationsTableCreateCompanionBuilder,
      $$LoanApplicationsTableUpdateCompanionBuilder,
      (
        LoanApplication,
        BaseReferences<_$AppDatabase, $LoanApplicationsTable, LoanApplication>,
      ),
      LoanApplication,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$DailyClosuresTableTableManager get dailyClosures =>
      $$DailyClosuresTableTableManager(_db, _db.dailyClosures);
  $$DebtorsTableTableManager get debtors =>
      $$DebtorsTableTableManager(_db, _db.debtors);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db, _db.debtPayments);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$LoanApplicationsTableTableManager get loanApplications =>
      $$LoanApplicationsTableTableManager(_db, _db.loanApplications);
}
