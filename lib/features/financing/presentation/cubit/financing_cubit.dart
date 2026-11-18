import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/usecases/evaluate_loan_eligibility_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/get_financial_partners_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/watch_loan_applications_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_state.dart';

class FinancingCubit extends Cubit<FinancingState> {
  FinancingCubit({
    required this.getFinancialPartnersUseCase,
    required this.evaluateLoanEligibilityUseCase,
    required this.watchLoanApplicationsUseCase,
    required this.passportRepository,
  }) : super(const FinancingState());

  final GetFinancialPartnersUseCase getFinancialPartnersUseCase;
  final EvaluateLoanEligibilityUseCase evaluateLoanEligibilityUseCase;
  final WatchLoanApplicationsUseCase watchLoanApplicationsUseCase;
  final PassportRepository passportRepository;

  StreamSubscription<List<LoanApplicationEntity>>? _appsSubscription;

  Future<void> loadFinancingData({String shopId = 'default-shop'}) async {
    emit(state.copyWith(status: FinancingStatus.loading));
    try {
      final partners = await getFinancialPartnersUseCase();

      // Récupération ou calcul du Passeport Financier
      final passportResult = await passportRepository.getFinancialPassport();
      final passport = switch (passportResult) {
        Success(data: final p) => p,
        Error() => null,
      };

      final eligibility = evaluateLoanEligibilityUseCase(
        passport: passport,
        partners: partners,
      );

      // Souscription réactive aux demandes de prêt déposées
      await _appsSubscription?.cancel();
      _appsSubscription = watchLoanApplicationsUseCase(shopId: shopId).listen(
        (apps) {
          emit(
            state.copyWith(
              status: FinancingStatus.loaded,
              applications: apps,
              partners: partners,
              eligibility: eligibility,
            ),
          );
        },
        onError: (Object error) {
          emit(
            state.copyWith(
              status: FinancingStatus.loaded,
              partners: partners,
              eligibility: eligibility,
              errorMessage: 'Impossible de charger les demandes en temps réel.',
            ),
          );
        },
      );

      emit(
        state.copyWith(
          status: FinancingStatus.loaded,
          partners: partners,
          eligibility: eligibility,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FinancingStatus.error,
          errorMessage: 'Erreur lors du chargement des options de financement.',
        ),
      );
    }
  }

  void selectPartner(FinancialPartnerEntity? partner) {
    if (partner == null) {
      emit(state.copyWith(clearSelectedPartner: true));
    } else {
      emit(state.copyWith(selectedPartner: partner));
    }
  }

  Future<void> refresh({String shopId = 'default-shop'}) async {
    await loadFinancingData(shopId: shopId);
  }

  @override
  Future<void> close() async {
    await _appsSubscription?.cancel();
    return super.close();
  }
}
