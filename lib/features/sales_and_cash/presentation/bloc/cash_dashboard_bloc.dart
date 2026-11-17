import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';

class CashDashboardBloc extends Bloc<CashDashboardEvent, CashDashboardState> {
  CashDashboardBloc({
    required this.watchTodaySalesUseCase,
  }) : super(const CashDashboardInitial()) {
    on<WatchCashDashboardStarted>(_onWatchCashDashboardStarted);
    on<CloseCashierTapped>(_onCloseCashierTapped);
    on<ResetClosureLock>(_onResetClosureLock);
  }

  final WatchTodaySalesUseCase watchTodaySalesUseCase;

  Future<void> _onWatchCashDashboardStarted(
    WatchCashDashboardStarted event,
    Emitter<CashDashboardState> emit,
  ) async {
    emit(const CashDashboardLoading());
    await emit.forEach<CashSummaryEntity>(
      watchTodaySalesUseCase(),
      onData: (summary) {
        final currentIsLocked = state is CashDashboardLoaded
            ? (state as CashDashboardLoaded).isClosureLocked
            : false;
        return CashDashboardLoaded(
          summary: summary,
          isClosureLocked: currentIsLocked,
        );
      },
      onError: (error, stackTrace) => CashDashboardError(
        message: 'Erreur lors de la lecture de la caisse : $error',
      ),
    );
  }

  void _onCloseCashierTapped(
    CloseCashierTapped event,
    Emitter<CashDashboardState> emit,
  ) {
    if (state is CashDashboardLoaded) {
      final current = state as CashDashboardLoaded;
      if (current.isClosureLocked) {
        return;
      }
      emit(current.copyWith(isClosureLocked: true));
    }
  }

  void _onResetClosureLock(
    ResetClosureLock event,
    Emitter<CashDashboardState> emit,
  ) {
    if (state is CashDashboardLoaded) {
      final current = state as CashDashboardLoaded;
      if (!current.isClosureLocked) {
        return;
      }
      emit(current.copyWith(isClosureLocked: false));
    }
  }
}
