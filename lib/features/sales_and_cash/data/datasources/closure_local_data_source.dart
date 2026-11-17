import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sales_and_cash/data/models/daily_closure_model.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

abstract class ClosureLocalDataSource {
  Future<int> getPrefillSalesAmount(DateTime cutoffTimestamp);
  Future<DailyClosureEntity> executeDailyClosure(DailyClosureEntity closure);
  Future<DailyClosureEntity?> getClosureById(String id);
  Future<List<DailyClosureEntity>> getAllClosures({
    int limit = 50,
    int? offset,
  });
}

class ClosureLocalDataSourceImpl implements ClosureLocalDataSource {
  ClosureLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<int> getPrefillSalesAmount(DateTime cutoffTimestamp) async {
    try {
      final cutoffIso = cutoffTimestamp.toUtc().toIso8601String();
      final sumColumn = database.sales.amount.sum();
      final query = database.selectOnly(database.sales)
        ..addColumns([sumColumn])
        ..where(
          database.sales.closureId.isNull() &
              database.sales.recordedAt.isSmallerOrEqualValue(cutoffIso),
        );
      final result = await query.getSingle();
      return result.read(sumColumn) ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to calculate prefill sales amount: $e');
    }
  }

  @override
  Future<DailyClosureEntity> executeDailyClosure(
    DailyClosureEntity closure,
  ) async {
    try {
      final cutoffIso = closure.cutoffTimestamp.toUtc().toIso8601String();
      await database.transaction(() async {
        // 1. Seal orphan sales created at or before cutoffTimestamp
        await (database.update(database.sales)
              ..where(
                (tbl) =>
                    tbl.closureId.isNull() &
                    tbl.recordedAt.isSmallerOrEqualValue(cutoffIso),
              ))
            .write(SalesCompanion(closureId: Value(closure.id)));

        // 2. Insert daily_closure row
        await database
            .into(database.dailyClosures)
            .insert(closure.toCompanion());
      });
      return closure;
    } catch (e) {
      throw DatabaseException('Failed to execute daily closure: $e');
    }
  }

  @override
  Future<DailyClosureEntity?> getClosureById(String id) async {
    try {
      final query = database.select(database.dailyClosures)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to get closure by id: $e');
    }
  }

  @override
  Future<List<DailyClosureEntity>> getAllClosures({
    int limit = 50,
    int? offset,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    if (offset != null && offset < 0) {
      throw ArgumentError('Offset cannot be negative');
    }
    try {
      final query = database.select(database.dailyClosures)
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.createdAt,
                mode: OrderingMode.desc,
              ),
        ])
        ..limit(limit, offset: offset);
      final rows = await query.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to get all closures: $e');
    }
  }
}
