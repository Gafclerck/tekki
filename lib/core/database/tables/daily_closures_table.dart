import 'package:drift/drift.dart';

@DataClassName('DailyClosure')
@TableIndex(name: 'daily_closures_date_idx', columns: {#closureDate})
@TableIndex(name: 'daily_closures_sync_status_idx', columns: {#syncStatus})
class DailyClosures extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().named('shop_id')();
  TextColumn get closureDate => text().named('closure_date')();
  TextColumn get cutoffTimestamp => text().named('cutoff_timestamp')();
  IntColumn get totalSalesAmount => integer().named('total_sales_amount')();
  IntColumn get totalCashDebtInflow => integer()
      .named('total_cash_debt_inflow')
      .withDefault(const Constant(0))();
  IntColumn get totalCreditSalesAmount => integer()
      .named('total_credit_sales_amount')
      .withDefault(const Constant(0))();
  IntColumn get totalExpensesAmount =>
      integer().named('total_expenses_amount').withDefault(const Constant(0))();
  IntColumn get cashCounted =>
      integer().named('cash_counted').withDefault(const Constant(0))();
  RealColumn get gpsLatitude => real().named('gps_latitude').nullable()();
  RealColumn get gpsLongitude => real().named('gps_longitude').nullable()();
  RealColumn get distanceMeters => real().named('distance_meters').nullable()();
  BoolColumn get isFlaggedLocation => boolean()
      .named('is_flagged_location')
      .withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get lastSyncedAt => text().named('last_synced_at').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
