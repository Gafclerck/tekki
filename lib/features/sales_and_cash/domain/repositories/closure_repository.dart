import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';

abstract class ClosureRepository {
  Future<Result<int, Failure>> getPrefillSalesAmount(DateTime cutoffTimestamp);
  Future<Result<DailyClosureEntity, Failure>> executeDailyClosure(
    DailyClosureEntity closure,
  );
  Future<Result<DailyClosureEntity?, Failure>> getClosureById(String id);
  Future<Result<List<DailyClosureEntity>, Failure>> getAllClosures({
    int limit = 50,
    int? offset,
  });
  Future<Result<int, Failure>> getMonthlyClosuresCount(
    DateTime date, {
    String? shopId,
  });
  Future<Result<int, Failure>> getActiveStreak({
    DateTime? referenceDate,
    String? shopId,
  });
  Future<Result<ShopEntity?, Failure>> getShopById(String id);
  Future<Result<ShopEntity?, Failure>> getShop();
}
