import 'package:drift/drift.dart';

@DataClassName('Shop')
class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get refLatitude => real().named('ref_latitude')();
  RealColumn get refLongitude => real().named('ref_longitude')();
  TextColumn get publicKey => text().named('public_key')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
