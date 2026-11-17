import 'package:equatable/equatable.dart';

sealed class CashDashboardEvent extends Equatable {
  const CashDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class WatchCashDashboardStarted extends CashDashboardEvent {
  const WatchCashDashboardStarted();
}

final class CloseCashierTapped extends CashDashboardEvent {
  const CloseCashierTapped();
}

final class ResetClosureLock extends CashDashboardEvent {
  const ResetClosureLock();
}
