import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/karne_bor/data/models/debt_model.dart';
import 'package:tekki/features/karne_bor/data/models/debt_payment_model.dart';
import 'package:tekki/features/karne_bor/data/models/debtor_model.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';

abstract class DebtLocalDataSource {
  Future<void> insertDebtor(DebtorEntity debtor);
  Future<void> updateDebtor(DebtorEntity debtor);
  Future<DebtorEntity?> getDebtorById(String id);
  Future<DebtorEntity?> findDebtorByName(String name);
  Future<List<DebtorEntity>> searchDebtors(String query, {int limit = 20});
  Future<List<DebtorEntity>> getAllDebtors({int limit = 50});
  Stream<List<DebtorEntity>> watchAllDebtors({int limit = 50});

  Future<void> insertDebt(DebtEntity debt);
  Future<void> recordDebtWithDebtor({
    required DebtorEntity debtor,
    required DebtEntity debt,
    bool isNewDebtor = true,
  });

  Future<void> recordDebtPayment({
    required DebtPaymentEntity payment,
    required DebtEntity updatedDebt,
  });
  Future<List<DebtPaymentEntity>> getPaymentsByDebt(String debtId);

  Future<DebtEntity?> getDebtById(String id);
  Future<List<DebtEntity>> getDebtsByDebtor(String debtorId);
  Future<List<DebtEntity>> getActiveDebts({int limit = 50, int? offset});
  Stream<List<DebtEntity>> watchActiveDebts({int limit = 50});
  Stream<List<DebtEntity>> watchAllDebtsWithDebtor({int limit = 50});

  Future<RecoveryVelocityEntity> getRecoveryVelocity({
    DateTime? asOf,
    int windowDays = 30,
  });
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  DebtLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<void> insertDebtor(DebtorEntity debtor) async {
    try {
      final companion = debtor.toCompanion();
      await database.into(database.debtors).insert(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert debtor: $e');
    }
  }

  @override
  Future<void> updateDebtor(DebtorEntity debtor) async {
    try {
      final companion = debtor.toCompanion();
      final updatedRows = await (database.update(
        database.debtors,
      )..where((tbl) => tbl.id.equals(debtor.id))).write(companion);
      if (updatedRows == 0) {
        throw DatabaseException('Debtor not found with id: ${debtor.id}');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to update debtor: $e');
    }
  }

  @override
  Future<DebtorEntity?> getDebtorById(String id) async {
    try {
      final query = database.select(database.debtors)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to get debtor by id: $e');
    }
  }

  @override
  Future<DebtorEntity?> findDebtorByName(String name) async {
    try {
      final trimmed = name.trim().toLowerCase();
      final query = database.select(database.debtors)
        ..where((tbl) => tbl.name.lower().equals(trimmed))
        ..limit(1);
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to find debtor by name: $e');
    }
  }

  @override
  Future<List<DebtorEntity>> searchDebtors(
    String query, {
    int limit = 20,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final trimmed = query.trim().toLowerCase();
      final select = database.select(database.debtors)
        ..where((tbl) => tbl.name.lower().contains(trimmed))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)])
        ..limit(limit);
      final rows = await select.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to search debtors: $e');
    }
  }

  @override
  Future<List<DebtorEntity>> getAllDebtors({int limit = 50}) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final query = database.select(database.debtors)
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)])
        ..limit(limit);
      final rows = await query.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to get all debtors: $e');
    }
  }

  @override
  Stream<List<DebtorEntity>> watchAllDebtors({int limit = 50}) {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final query = database.select(database.debtors)
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)])
        ..limit(limit);
      return query.watch().map(
        (rows) => rows.map((r) => r.toEntity()).toList(),
      );
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to watch all debtors: $e');
    }
  }

  @override
  Future<void> insertDebt(DebtEntity debt) async {
    try {
      final companion = debt.toCompanion();
      await database.into(database.debts).insert(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert debt: $e');
    }
  }

  @override
  Future<void> recordDebtWithDebtor({
    required DebtorEntity debtor,
    required DebtEntity debt,
    bool isNewDebtor = true,
  }) async {
    try {
      await database.transaction(() async {
        if (isNewDebtor) {
          final debtorCompanion = debtor.toCompanion();
          await database.into(database.debtors).insert(debtorCompanion);
        }
        final debtCompanion = debt.toCompanion();
        await database.into(database.debts).insert(debtCompanion);
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to record debt with debtor atomically: $e',
      );
    }
  }

  @override
  Future<DebtEntity?> getDebtById(String id) async {
    try {
      final query = database.select(database.debts)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      if (row == null) return null;

      final debtor = await getDebtorById(row.debtorId);
      return row.toEntity(
        debtor: debtor != null
            ? DebtorModel.fromEntity(debtor).toDrift()
            : null,
      );
    } catch (e) {
      throw DatabaseException('Failed to get debt by id: $e');
    }
  }

  @override
  Future<List<DebtEntity>> getDebtsByDebtor(String debtorId) async {
    try {
      final debtor = await getDebtorById(debtorId);
      final debtorDrift = debtor != null
          ? DebtorModel.fromEntity(debtor).toDrift()
          : null;

      final query = database.select(database.debts)
        ..where((tbl) => tbl.debtorId.equals(debtorId))
        ..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ]);
      final rows = await query.get();
      return rows.map((r) => r.toEntity(debtor: debtorDrift)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get debts by debtor: $e');
    }
  }

  @override
  Future<List<DebtEntity>> getActiveDebts({int limit = 50, int? offset}) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    if (offset != null && offset < 0) {
      throw ArgumentError('Offset cannot be negative');
    }
    try {
      final query = database.select(database.debts)
        ..where(
          (tbl) => tbl.status.isIn([
            DebtStatus.active.toValue(),
            DebtStatus.overdue.toValue(),
          ]),
        )
        ..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.dueDate, mode: OrderingMode.asc),
        ])
        ..limit(limit, offset: offset);
      final rows = await query.get();

      final result = <DebtEntity>[];
      for (final row in rows) {
        final debtor = await getDebtorById(row.debtorId);
        result.add(
          row.toEntity(
            debtor: debtor != null
                ? DebtorModel.fromEntity(debtor).toDrift()
                : null,
          ),
        );
      }
      return result;
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to get active debts: $e');
    }
  }

  @override
  Stream<List<DebtEntity>> watchActiveDebts({int limit = 50}) {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final query =
          database.select(database.debts).join([
              innerJoin(
                database.debtors,
                database.debtors.id.equalsExp(database.debts.debtorId),
              ),
            ])
            ..where(
              database.debts.status.isIn([
                DebtStatus.active.toValue(),
                DebtStatus.overdue.toValue(),
              ]),
            )
            ..orderBy([
              OrderingTerm(
                expression: database.debts.dueDate,
                mode: OrderingMode.asc,
              ),
            ])
            ..limit(limit);

      return query.watch().map((rows) {
        return rows.map((row) {
          final debtRow = row.readTable(database.debts);
          final debtorRow = row.readTable(database.debtors);
          return debtRow.toEntity(debtor: debtorRow);
        }).toList();
      });
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to watch active debts: $e');
    }
  }

  @override
  Stream<List<DebtEntity>> watchAllDebtsWithDebtor({int limit = 50}) {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    try {
      final query =
          database.select(database.debts).join([
              innerJoin(
                database.debtors,
                database.debtors.id.equalsExp(database.debts.debtorId),
              ),
            ])
            ..orderBy([
              OrderingTerm(
                expression: database.debts.createdAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit);

      return query.watch().map((rows) {
        return rows.map((row) {
          final debtRow = row.readTable(database.debts);
          final debtorRow = row.readTable(database.debtors);
          return debtRow.toEntity(debtor: debtorRow);
        }).toList();
      });
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to watch all debts with debtor: $e');
    }
  }

  @override
  Future<void> recordDebtPayment({
    required DebtPaymentEntity payment,
    required DebtEntity updatedDebt,
  }) async {
    try {
      await database.transaction(() async {
        final paymentCompanion = DebtPaymentModel.fromEntity(
          payment,
        ).toCompanion();
        await database.into(database.debtPayments).insert(paymentCompanion);

        await (database.update(
          database.debts,
        )..where((tbl) => tbl.id.equals(updatedDebt.id))).write(
          DebtsCompanion(
            remainingAmount: Value(updatedDebt.remainingAmount),
            status: Value(updatedDebt.status.toValue()),
          ),
        );
      });
    } catch (e) {
      throw DatabaseException('Failed to record debt payment atomically: $e');
    }
  }

  @override
  Future<List<DebtPaymentEntity>> getPaymentsByDebt(String debtId) async {
    try {
      final query = database.select(database.debtPayments)
        ..where((tbl) => tbl.debtId.equals(debtId))
        ..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.paidAt, mode: OrderingMode.desc),
        ]);
      final rows = await query.get();
      return rows.map((r) => DebtPaymentModel.fromDrift(r).toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to get payments by debt: $e');
    }
  }

  @override
  Future<RecoveryVelocityEntity> getRecoveryVelocity({
    DateTime? asOf,
    int windowDays = 30,
  }) async {
    try {
      final referenceDate = (asOf ?? DateTime.now()).toUtc();
      final windowStart = DateTime.utc(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      ).subtract(Duration(days: windowDays));
      final windowStartStr = windowStart.toIso8601String();

      final debtsQuery = database.select(database.debts)
        ..where(
          (tbl) =>
              tbl.dueDate.isBiggerOrEqualValue(windowStartStr) |
              tbl.createdAt.isBiggerOrEqualValue(windowStartStr),
        );
      final debtRows = await debtsQuery.get();

      if (debtRows.isEmpty) {
        return CalculateRecoveryVelocityUseCase.calculatePure(
          totalDueAmount: 0,
          totalRecoveredAmount: 0,
          windowDays: windowDays,
        );
      }

      final debtsSubquery = database.selectOnly(database.debts)
        ..addColumns([database.debts.id])
        ..where(
          database.debts.dueDate.isBiggerOrEqualValue(windowStartStr) |
              database.debts.createdAt.isBiggerOrEqualValue(windowStartStr),
        );
      final paymentsQuery = database.select(database.debtPayments)
        ..where((tbl) => tbl.debtId.isInQuery(debtsSubquery));
      final paymentRows = await paymentsQuery.get();

      final paymentsByDebtId = <String, List<DebtPaymentEntity>>{};
      for (final p in paymentRows) {
        final entity = DebtPaymentModel.fromDrift(p).toEntity();
        paymentsByDebtId.putIfAbsent(p.debtId, () => []).add(entity);
      }

      final debtEntities = debtRows.map((r) => r.toEntity()).toList();

      return CalculateRecoveryVelocityUseCase.computeFromDebts(
        debts: debtEntities,
        paymentsByDebtId: paymentsByDebtId,
        asOf: referenceDate,
        windowDays: windowDays,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to get recovery velocity: $e');
    }
  }
}
