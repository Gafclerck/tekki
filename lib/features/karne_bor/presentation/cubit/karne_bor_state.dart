import 'package:equatable/equatable.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';

sealed class KarneBorState extends Equatable {
  const KarneBorState();

  @override
  List<Object?> get props => [];
}

final class KarneBorInitial extends KarneBorState {
  const KarneBorInitial();
}

final class KarneBorLoading extends KarneBorState {
  const KarneBorLoading();
}

final class KarneBorLoaded extends KarneBorState {
  const KarneBorLoaded({
    required this.debts,
    required this.totalDebt,
    this.overdueCount = 0,
    this.recoveryVelocity,
    this.recoveryRate = 100,
  });

  final List<DebtEntity> debts;
  final int totalDebt;
  final int overdueCount;
  final RecoveryVelocityEntity? recoveryVelocity;
  final int recoveryRate;

  bool get isEmpty => debts.isEmpty;
  bool get hasOverdue => overdueCount > 0;

  @override
  List<Object?> get props => [
        debts,
        totalDebt,
        overdueCount,
        recoveryVelocity,
        recoveryRate,
      ];
}

final class KarneBorError extends KarneBorState {
  const KarneBorError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
