import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/usecases/submit_loan_application_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/loan_application_form_state.dart';
import 'package:uuid/uuid.dart';

class LoanApplicationFormCubit extends Cubit<LoanApplicationFormState> {
  LoanApplicationFormCubit({
    required this.submitLoanApplicationUseCase,
    FinancialPartnerEntity? initialPartner,
    int? initialAmount,
  }) : super(
         LoanApplicationFormState(
           selectedPartner: initialPartner,
           requestedAmount: initialAmount ?? 500000,
           durationMonths: initialPartner?.minDurationMonths ?? 6,
           estimatedMonthlyPayment: _computePayment(
             initialPartner,
             initialAmount ?? 500000,
             initialPartner?.minDurationMonths ?? 6,
           ),
         ),
       );

  final SubmitLoanApplicationUseCase submitLoanApplicationUseCase;
  static const Uuid _uuid = Uuid();

  static int _computePayment(
    FinancialPartnerEntity? partner,
    int amount,
    int durationMonths,
  ) {
    if (partner == null || durationMonths <= 0) return 0;
    return partner.calculateEstimatedMonthlyPayment(
      amount: amount,
      durationMonths: durationMonths,
    );
  }

  void setPartner(FinancialPartnerEntity partner) {
    final payment = _computePayment(
      partner,
      state.requestedAmount,
      state.durationMonths,
    );
    emit(
      state.copyWith(
        selectedPartner: partner,
        estimatedMonthlyPayment: payment,
        clearError: true,
      ),
    );
  }

  void setAmount(int amount) {
    final payment = _computePayment(
      state.selectedPartner,
      amount,
      state.durationMonths,
    );
    emit(
      state.copyWith(
        requestedAmount: amount,
        estimatedMonthlyPayment: payment,
        clearError: true,
      ),
    );
  }

  void setDuration(int months) {
    final payment = _computePayment(
      state.selectedPartner,
      state.requestedAmount,
      months,
    );
    emit(
      state.copyWith(
        durationMonths: months,
        estimatedMonthlyPayment: payment,
        clearError: true,
      ),
    );
  }

  void setPurpose(LoanPurpose purpose) {
    emit(state.copyWith(purpose: purpose, clearError: true));
  }

  void toggleConsent(bool consent) {
    emit(state.copyWith(consentSharePassport: consent, clearError: true));
  }

  Future<void> submit({required String shopId, int currentScore = 0}) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          errorMessage:
              'Veuillez renseigner tous les champs obligatoires et valider le partage du Passeport.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final application = LoanApplicationEntity(
      id: _uuid.v4(),
      shopId: shopId,
      partnerId: state.selectedPartner!.id,
      partnerName: state.selectedPartner!.name,
      requestedAmount: state.requestedAmount,
      durationMonths: state.durationMonths,
      monthlyPaymentEstimate: state.estimatedMonthlyPayment,
      purpose: state.purpose,
      status: LoanStatus.pending,
      submissionDate: DateTime.now(),
      passportScoreAtSubmission: currentScore,
      createdAt: DateTime.now(),
    );

    final result = await submitLoanApplicationUseCase(application);

    switch (result) {
      case Success(data: final savedApp):
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            submittedApplication: savedApp,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(isSubmitting: false, errorMessage: failure.message),
        );
    }
  }
}
