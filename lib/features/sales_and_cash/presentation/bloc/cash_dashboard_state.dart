import 'package:equatable/equatable.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

sealed class CashDashboardState extends Equatable {
  const CashDashboardState();

  @override
  List<Object?> get props => [];
}

final class CashDashboardInitial extends CashDashboardState {
  const CashDashboardInitial();
}

final class CashDashboardLoading extends CashDashboardState {
  const CashDashboardLoading();
}

final class CashDashboardLoaded extends CashDashboardState {
  const CashDashboardLoaded({
    required this.summary,
    this.isClosureLocked = false,
  });

  final CashSummaryEntity summary;
  final bool isClosureLocked;

  int get totalAmount => summary.totalAmount;
  int get salesCount => summary.salesCount;
  List<SaleEntity> get sales => summary.sales;
  bool get isEmpty => summary.salesCount == 0;

  CashDashboardLoaded copyWith({
    CashSummaryEntity? summary,
    bool? isClosureLocked,
  }) {
    return CashDashboardLoaded(
      summary: summary ?? this.summary,
      isClosureLocked: isClosureLocked ?? this.isClosureLocked,
    );
  }

  @override
  List<Object?> get props => [summary, isClosureLocked];
}

final class CashDashboardError extends CashDashboardState {
  const CashDashboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
