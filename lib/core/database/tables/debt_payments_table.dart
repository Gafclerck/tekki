import 'package:drift/drift.dart';
import 'package:tekki/core/database/tables/daily_closures_table.dart';
import 'package:tekki/core/database/tables/debts_table.dart';

@DataClassName('DebtPayment')
@TableIndex(name: 'debt_payments_debt_id_idx', columns: {#debtId})
@TableIndex(name: 'debt_payments_payment_method_idx', columns: {#paymentMethod})
@TableIndex(name: 'debt_payments_sync_status_idx', columns: {#syncStatus})
@TableIndex(name: 'debt_payments_closure_id_idx', columns: {#closureId})
class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text().named('debt_id').references(Debts, #id)();
  IntColumn get paymentAmount => integer().named('payment_amount')();
  TextColumn get paymentMethod =>
      text().named('payment_method').withDefault(const Constant('ESPECES'))();
  TextColumn get closureId =>
      text().named('closure_id').nullable().references(DailyClosures, #id)();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get lastSyncedAt => text().named('last_synced_at').nullable()();
  TextColumn get paidAt => text().named('paid_at')();

  @override
  Set<Column> get primaryKey => {id};
}
