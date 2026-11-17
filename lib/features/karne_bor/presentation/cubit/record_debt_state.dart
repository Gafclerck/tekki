import 'package:equatable/equatable.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

sealed class RecordDebtState extends Equatable {
  const RecordDebtState();

  @override
  List<Object?> get props => [];
}

final class RecordDebtInitial extends RecordDebtState {
  const RecordDebtInitial({this.knownDebtors = const []});

  final List<DebtorEntity> knownDebtors;

  @override
  List<Object?> get props => [knownDebtors];
}

final class RecordDebtSubmitting extends RecordDebtState {
  const RecordDebtSubmitting();
}

final class RecordDebtSuccess extends RecordDebtState {
  const RecordDebtSuccess({required this.debt});

  final DebtEntity debt;

  @override
  List<Object?> get props => [debt];
}

final class RecordDebtFailure extends RecordDebtState {
  const RecordDebtFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
