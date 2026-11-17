import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/usecases/evaluate_financial_health_use_case.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';

/// Cubit gérant l'évaluation et l'état réactif de santé financière du Conseiller Tekki.
class AdvisorCubit extends Cubit<AdvisorState> {
  AdvisorCubit({required this.evaluateFinancialHealthUseCase})
    : super(const AdvisorInitial());

  final EvaluateFinancialHealthUseCase evaluateFinancialHealthUseCase;

  Future<void> loadFinancialHealth({
    DateTime? asOf,
    int windowDays = 30,
  }) async {
    emit(const AdvisorLoading());

    final result = await evaluateFinancialHealthUseCase(
      asOf: asOf,
      windowDays: windowDays,
    );

    switch (result) {
      case Success(data: final health):
        emit(AdvisorLoaded(financialHealth: health));
      case Error(failure: final failure):
        emit(AdvisorError(message: failure.message));
    }
  }
}
