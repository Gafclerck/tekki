import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';

class WatchTodaySalesUseCase {
  const WatchTodaySalesUseCase({
    required this.repository,
    DateTime Function()? nowProvider,
  }) : _nowProvider = nowProvider ?? DateTime.now;

  final SalesRepository repository;
  final DateTime Function() _nowProvider;

  Stream<CashSummaryEntity> call() {
    return repository.watchOrphanSales().map((sales) {
      final now = _nowProvider().toLocal();
      final todaySales = sales.where((sale) {
        if (sale.closureId != null) {
          return false;
        }
        final localDate = sale.recordedAt.toLocal();
        return localDate.year == now.year &&
            localDate.month == now.month &&
            localDate.day == now.day;
      }).toList();

      final totalAmount = todaySales.fold<int>(
        0,
        (sum, sale) => sum + sale.amount,
      );

      return CashSummaryEntity(
        totalAmount: totalAmount,
        salesCount: todaySales.length,
        sales: todaySales,
      );
    });
  }
}
