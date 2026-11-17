import 'package:drift/drift.dart';

@DataClassName('Debtor')
@TableIndex(name: 'debtors_sync_status_idx', columns: {#syncStatus})
class Debtors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().named('phone_number').nullable()();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
