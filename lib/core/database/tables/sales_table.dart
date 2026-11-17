import 'package:drift/drift.dart';

@DataClassName('Sale')
@TableIndex(name: 'sales_closure_id_idx', columns: {#closureId})
@TableIndex(name: 'sales_sync_status_idx', columns: {#syncStatus})
class Sales extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  TextColumn get paymentMethod => text().named('payment_method')();
  TextColumn get recordedAt => text().named('recorded_at')();
  TextColumn get closureId => text().named('closure_id').nullable()();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get lastSyncedAt => text().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
