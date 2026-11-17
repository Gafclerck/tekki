import 'package:drift/drift.dart';
import 'package:tekki/core/database/tables/debtors_table.dart';

@DataClassName('Debt')
@TableIndex(name: 'debts_debtor_id_idx', columns: {#debtorId})
@TableIndex(name: 'debts_status_idx', columns: {#status})
@TableIndex(name: 'debts_sync_status_idx', columns: {#syncStatus})
class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get debtorId =>
      text().named('debtor_id').references(Debtors, #id)();
  IntColumn get initialAmount => integer().named('initial_amount')();
  IntColumn get remainingAmount => integer().named('remaining_amount')();
  TextColumn get dueDate => text().named('due_date')();
  TextColumn get status =>
      text().named('status').withDefault(const Constant('ACTIVE'))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get lastSyncedAt => text().named('last_synced_at').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
