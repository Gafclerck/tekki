import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/sales_and_cash/data/models/sale_model.dart';
import 'package:tekki/features/sales_and_cash/data/models/shop_model.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

abstract class SalesLocalDataSource {
  Future<void> insertSale(SaleEntity sale);
  Future<SaleEntity?> getSaleById(String id);
  Future<List<SaleEntity>> getAllSales({int limit = 50, int? offset});
  Future<List<SaleEntity>> getOrphanSales();
  Stream<List<SaleEntity>> watchOrphanSales();
  Stream<List<SaleEntity>> watchAllSales({int limit = 50, int? offset});

  Future<void> insertShop(ShopEntity shop);
  Future<ShopEntity?> getShop();
  Future<ShopEntity?> getShopById(String id);
  Stream<ShopEntity?> watchShop();
}

class SalesLocalDataSourceImpl implements SalesLocalDataSource {
  SalesLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<void> insertSale(SaleEntity sale) async {
    try {
      final companion = sale.toCompanion();
      await database.into(database.sales).insert(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert sale: $e');
    }
  }

  @override
  Future<SaleEntity?> getSaleById(String id) async {
    try {
      final query = database.select(database.sales)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      return row?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to get sale by id: $e');
    }
  }

  @override
  Future<List<SaleEntity>> getAllSales({int limit = 50, int? offset}) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    if (offset != null && offset < 0) {
      throw ArgumentError('Offset cannot be negative');
    }
    try {
      final query = database.select(database.sales)
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.recordedAt,
                mode: OrderingMode.desc,
              ),
        ])
        ..limit(limit, offset: offset);
      final rows = await query.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to get all sales: $e');
    }
  }

  @override
  Future<List<SaleEntity>> getOrphanSales() async {
    try {
      final query = database.select(database.sales)
        ..where((tbl) => tbl.closureId.isNull())
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.recordedAt,
                mode: OrderingMode.asc,
              ),
        ]);
      final rows = await query.get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to get orphan sales: $e');
    }
  }

  @override
  Stream<List<SaleEntity>> watchOrphanSales() {
    try {
      final query = database.select(database.sales)
        ..where((tbl) => tbl.closureId.isNull())
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.recordedAt,
                mode: OrderingMode.asc,
              ),
        ]);
      return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      throw DatabaseException('Failed to watch orphan sales: $e');
    }
  }

  @override
  Stream<List<SaleEntity>> watchAllSales({int limit = 50, int? offset}) {
    if (limit <= 0) {
      throw ArgumentError('Limit must be strictly positive');
    }
    if (offset != null && offset < 0) {
      throw ArgumentError('Offset cannot be negative');
    }
    try {
      final query = database.select(database.sales)
        ..orderBy([
          (tbl) => OrderingTerm(
                expression: tbl.recordedAt,
                mode: OrderingMode.desc,
              ),
        ])
        ..limit(limit, offset: offset);
      return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw DatabaseException('Failed to watch all sales: $e');
    }
  }

  @override
  Future<void> insertShop(ShopEntity shop) async {
    try {
      final companion = shop.toCompanion();
      await database.into(database.shops).insert(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert shop: $e');
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
  Stream<ShopEntity?> watchShop() {
    try {
      final query = database.select(database.shops)..limit(1);
      return query.watchSingleOrNull().map((row) => row?.toEntity());
    } catch (e) {
      throw DatabaseException('Failed to watch shop: $e');
    }
  }
}
