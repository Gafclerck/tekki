import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sales_and_cash/data/models/daily_closure_model.dart';
import 'package:tekki/features/sales_and_cash/data/models/shop_model.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';
import 'package:uuid/uuid.dart';

abstract class ClosureLocalDataSource {
  Future<int> getPrefillSalesAmount(DateTime cutoffTimestamp);
  Future<int> getPrefillDebtCashInflow(DateTime cutoffTimestamp);
  Future<DailyClosureEntity> executeDailyClosure(DailyClosureEntity closure);
  Future<DailyClosureEntity?> getClosureById(String id);
  Future<List<DailyClosureEntity>> getAllClosures({
    int limit = 50,
    int? offset,
  });
  Future<int> getMonthlyClosuresCount(DateTime date, {String? shopId});
  Future<int> getActiveStreak({DateTime? referenceDate, String? shopId});
  Future<ShopEntity?> getShopById(String id);
  Future<ShopEntity?> getShop();
}

class ClosureLocalDataSourceImpl implements ClosureLocalDataSource {
  ClosureLocalDataSourceImpl({required this.database});

  final AppDatabase database;
  static const _uuid = Uuid();

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
  Future<int> getPrefillDebtCashInflow(DateTime cutoffTimestamp) async {
    try {
      final cutoffIso = cutoffTimestamp.toUtc().toIso8601String();
      final sumColumn = database.debtPayments.paymentAmount.sum();
      final query = database.selectOnly(database.debtPayments)
        ..addColumns([sumColumn])
        ..where(
          database.debtPayments.closureId.isNull() &
              database.debtPayments.paymentMethod.equals('ESPECES') &
              database.debtPayments.paidAt.isSmallerOrEqualValue(cutoffIso),
        );
      final result = await query.getSingle();
      return result.read(sumColumn) ?? 0;
    } catch (e) {
      throw DatabaseException(
        'Failed to calculate prefill debt cash inflow: $e',
      );
    }
  }

  @override
  Future<DailyClosureEntity> executeDailyClosure(
    DailyClosureEntity closure,
  ) async {
    try {
      final cutoffIso = closure.cutoffTimestamp.toUtc().toIso8601String();
      await database.transaction(() async {
        // 1. Insert daily_closure row first (so foreign keys on closure_id are valid)
        await database
            .into(database.dailyClosures)
            .insert(closure.toCompanion());

        // 2. Seal orphan sales created at or before cutoffTimestamp
        await (database.update(database.sales)..where(
              (tbl) =>
                  tbl.closureId.isNull() &
                  tbl.recordedAt.isSmallerOrEqualValue(cutoffIso),
            ))
            .write(SalesCompanion(closureId: Value(closure.id)));

        // 3. Seal orphan cash debt payments created at or before cutoffTimestamp
        await (database.update(database.debtPayments)..where(
              (tbl) =>
                  tbl.closureId.isNull() &
                  tbl.paidAt.isSmallerOrEqualValue(cutoffIso),
            ))
            .write(DebtPaymentsCompanion(closureId: Value(closure.id)));

        // 4. Atomically insert outbox event for daily closure
        final payloadJson = jsonEncode(
          DailyClosureModel.fromEntity(closure).toJson(),
        );
        await database
            .into(database.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                clientEventId: _uuid.v4(),
                eventType: 'CLOSURE_SUBMITTED',
                targetTable: 'daily_closures',
                targetId: closure.id,
                payloadJson: payloadJson,
                createdAt: DateTime.now().toUtc().toIso8601String(),
              ),
            );
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
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ])
        ..limit(limit, offset: offset);
      final rows = await query.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to get all closures: $e');
    }
  }

  @override
  Future<int> getMonthlyClosuresCount(DateTime date, {String? shopId}) async {
    try {
      final yearStr = date.year.toString().padLeft(4, '0');
      final monthStr = date.month.toString().padLeft(2, '0');
      final prefix = '$yearStr-$monthStr';

      final countColumn = database.dailyClosures.id.count();
      Expression<bool> predicate = database.dailyClosures.closureDate.like(
        '$prefix%',
      );
      if (shopId != null && shopId.isNotEmpty) {
        predicate = predicate & database.dailyClosures.shopId.equals(shopId);
      }

      final query = database.selectOnly(database.dailyClosures)
        ..addColumns([countColumn])
        ..where(predicate);

      final result = await query.getSingle();
      return result.read(countColumn) ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get monthly closures count: $e');
    }
  }

  @override
  Future<int> getActiveStreak({DateTime? referenceDate, String? shopId}) async {
    try {
      final ref = (referenceDate ?? DateTime.now()).toUtc();

      var query = database.select(database.dailyClosures);
      if (shopId != null && shopId.isNotEmpty) {
        query = query..where((tbl) => tbl.shopId.equals(shopId));
      }
      query = query..orderBy([(tbl) => OrderingTerm.desc(tbl.closureDate)]);

      final closures = await query.get();
      if (closures.isEmpty) return 0;

      final closedDates = closures.map((c) => c.closureDate).toSet();

      String format(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final todayStr = format(ref);
      final yesterdayStr = format(ref.subtract(const Duration(days: 1)));

      DateTime currentCheckDate;
      if (closedDates.contains(todayStr)) {
        currentCheckDate = ref;
      } else if (closedDates.contains(yesterdayStr)) {
        currentCheckDate = ref.subtract(const Duration(days: 1));
      } else {
        return 0;
      }

      int streak = 0;
      while (closedDates.contains(format(currentCheckDate))) {
        streak++;
        currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      throw DatabaseException('Failed to calculate active streak: $e');
    }
  }

  @override
  Future<ShopEntity?> getShopById(String id) async {
    try {
      final query = database.select(database.shops)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to get shop by id: $e');
    }
  }

  @override
  Future<ShopEntity?> getShop() async {
    try {
      final query = database.select(database.shops)..limit(1);
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to get shop: $e');
    }
  }
}
