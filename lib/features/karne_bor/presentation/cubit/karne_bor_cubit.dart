import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';

class KarneBorCubit extends Cubit<KarneBorState> {
  KarneBorCubit({
    required this.watchActiveDebtsUseCase,
    this.calculateRecoveryVelocityUseCase,
  }) : super(const KarneBorInitial());

  final WatchActiveDebtsUseCase watchActiveDebtsUseCase;
  final CalculateRecoveryVelocityUseCase? calculateRecoveryVelocityUseCase;
  StreamSubscription<List<DebtEntity>>? _subscription;

  void startWatching() {
    emit(const KarneBorLoading());
    _subscription?.cancel();
    _subscription = watchActiveDebtsUseCase().listen(
      (debts) async {
        if (isClosed) return;
        final totalDebt = debts.fold<int>(
          0,
          (sum, d) => sum + d.remainingAmount,
        );
        final overdueCount = debts.where((d) => d.isOverdue).length;

        final sortedDebts = List<DebtEntity>.from(debts)
          ..sort((a, b) {
            if (a.isOverdue && !b.isOverdue) return -1;
            if (!a.isOverdue && b.isOverdue) return 1;
            final dueCmp = a.dueDate.compareTo(b.dueDate);
            if (dueCmp != 0) return dueCmp;
            return a.createdAt.compareTo(b.createdAt);
          });

        RecoveryVelocityEntity? velocity;
        int recoveryRate = 100;
        if (calculateRecoveryVelocityUseCase != null) {
          final velocityResult = await calculateRecoveryVelocityUseCase!();
          velocity = velocityResult.fold(
            onSuccess: (v) => v,
            onError: (_) => null,
          );
          if (velocity != null) {
            recoveryRate = velocity.rate;
          }
        }

        if (isClosed) return;

        emit(
          KarneBorLoaded(
            debts: sortedDebts,
            totalDebt: totalDebt,
            overdueCount: overdueCount,
            recoveryVelocity: velocity,
            recoveryRate: recoveryRate,
          ),
        );
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
