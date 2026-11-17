import 'package:equatable/equatable.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

class CashSummaryEntity extends Equatable {
  CashSummaryEntity({
    required this.totalAmount,
    required this.salesCount,
    required List<SaleEntity> sales,
  }) : sales = List.unmodifiable(sales) {
    if (totalAmount < 0) {
      throw ArgumentError('totalAmount cannot be negative');
    }
    if (salesCount < 0) {
      throw ArgumentError('salesCount cannot be negative');
    }
  }

  const CashSummaryEntity.empty()
      : totalAmount = 0,
        salesCount = 0,
        sales = const [];

  final int totalAmount;
  final int salesCount;
  final List<SaleEntity> sales;

  @override
  List<Object?> get props => [totalAmount, salesCount, sales];
}
