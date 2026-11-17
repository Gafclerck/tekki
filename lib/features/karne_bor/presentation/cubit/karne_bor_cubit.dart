import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';

class KarneBorCubit extends Cubit<KarneBorState> {
  KarneBorCubit({
    required this.watchActiveDebtsUseCase,
  }) : super(const KarneBorInitial());

  final WatchActiveDebtsUseCase watchActiveDebtsUseCase;
  StreamSubscription<List<DebtEntity>>? _subscription;

  void startWatching() {
    emit(const KarneBorLoading());
    _subscription?.cancel();
    _subscription = watchActiveDebtsUseCase().listen(
      (debts) {
        final totalDebt = debts.fold<int>(
          0,
          (sum, d) => sum + d.remainingAmount,
        );
        emit(KarneBorLoaded(debts: debts, totalDebt: totalDebt));
      },
      onError: (Object e) {
        emit(KarneBorError(message: 'Impossible de charger le carnet: $e'));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
