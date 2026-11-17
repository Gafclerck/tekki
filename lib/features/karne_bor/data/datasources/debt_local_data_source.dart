import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/karne_bor/data/models/debt_model.dart';
import 'package:tekki/features/karne_bor/data/models/debtor_model.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

abstract class DebtLocalDataSource {
  Future<void> insertDebtor(DebtorEntity debtor);
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

  Future<DebtEntity?> getDebtById(String id);
  Future<List<DebtEntity>> getDebtsByDebtor(String debtorId);
  Future<List<DebtEntity>> getActiveDebts({int limit = 50, int? offset});
  Stream<List<DebtEntity>> watchActiveDebts({int limit = 50});
  Stream<List<DebtEntity>> watchAllDebtsWithDebtor({int limit = 50});
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
  Future<List<DebtorEntity>> searchDebtors(String query, {int limit = 20}) async {
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
      return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
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
      throw DatabaseException('Failed to record debt with debtor atomically: $e');
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
      return row.toEntity(debtor: debtor != null ? DebtorModel.fromEntity(debtor).toDrift() : null);
    } catch (e) {
      throw DatabaseException('Failed to get debt by id: $e');
    }
  }

  @override
  Future<List<DebtEntity>> getDebtsByDebtor(String debtorId) async {
    try {
      final debtor = await getDebtorById(debtorId);
      final debtorDrift = debtor != null ? DebtorModel.fromEntity(debtor).toDrift() : null;

      final query = database.select(database.debts)
        ..where((tbl) => tbl.debtorId.equals(debtorId))
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.createdAt,
                mode: OrderingMode.desc,
              ),
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
          (tbl) => OrderingTerm(
                expression: tbl.dueDate,
                mode: OrderingMode.asc,
              ),
        ])
        ..limit(limit, offset: offset);
      final rows = await query.get();

      final result = <DebtEntity>[];
      for (final row in rows) {
        final debtor = await getDebtorById(row.debtorId);
        result.add(
          row.toEntity(
            debtor: debtor != null ? DebtorModel.fromEntity(debtor).toDrift() : null,
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
      final query = database.select(database.debts).join([
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
      final query = database.select(database.debts).join([
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
}
