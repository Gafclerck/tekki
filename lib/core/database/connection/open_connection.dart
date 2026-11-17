import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection({String dbName = 'tekki', bool inMemory = false}) {
  if (inMemory) {
    return NativeDatabase.memory();
  }
  return driftDatabase(name: dbName);
}
