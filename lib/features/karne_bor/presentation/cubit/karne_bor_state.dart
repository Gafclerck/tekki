import 'package:equatable/equatable.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';

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
  const KarneBorLoaded({required this.debts, required this.totalDebt});

  final List<DebtEntity> debts;
  final int totalDebt;

  bool get isEmpty => debts.isEmpty;

  @override
  List<Object?> get props => [debts, totalDebt];
}

final class KarneBorError extends KarneBorState {
  const KarneBorError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
