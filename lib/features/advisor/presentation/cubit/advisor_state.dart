import 'package:equatable/equatable.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';

abstract class AdvisorState extends Equatable {
  const AdvisorState();

  @override
  List<Object?> get props => [];
}

class AdvisorInitial extends AdvisorState {
  const AdvisorInitial();
}

class AdvisorLoading extends AdvisorState {
  const AdvisorLoading();
}

class AdvisorLoaded extends AdvisorState {
  const AdvisorLoaded({required this.financialHealth});

  final FinancialHealthEntity financialHealth;

  @override
  List<Object?> get props => [financialHealth];
}

class AdvisorError extends AdvisorState {
  const AdvisorError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
