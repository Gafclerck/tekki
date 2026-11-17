import 'package:drift/drift.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/database/tables/daily_closures_table.dart';
import 'package:tekki/core/database/tables/sales_table.dart';
import 'package:tekki/core/database/tables/shops_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Shops, Sales, DailyClosures])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
          await customStatement('PRAGMA synchronous = NORMAL;');
        },
      );
}
