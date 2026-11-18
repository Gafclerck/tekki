import 'package:drift/drift.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/database/tables/daily_closures_table.dart';
import 'package:tekki/core/database/tables/debt_payments_table.dart';
import 'package:tekki/core/database/tables/debtors_table.dart';
import 'package:tekki/core/database/tables/debts_table.dart';
import 'package:tekki/core/database/tables/sales_table.dart';
import 'package:tekki/core/database/tables/shops_table.dart';
import 'package:tekki/core/database/tables/sync_outbox_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Shops,
    Sales,
    DailyClosures,
    Debtors,
    Debts,
    DebtPayments,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(debtors);
        await m.createTable(debts);
      }
      if (from < 3) {
        await m.createTable(debtPayments);
      }
      if (from < 4) {
        await m.createTable(syncOutbox);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA synchronous = NORMAL;');
    },
  );
}
