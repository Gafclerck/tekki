import 'package:equatable/equatable.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';

class LoanApplicationFormState extends Equatable {
  const LoanApplicationFormState({
    this.selectedPartner,
    this.requestedAmount = 500000,
    this.durationMonths = 6,
    this.purpose = LoanPurpose.stock,
    this.consentSharePassport = true,
    this.estimatedMonthlyPayment = 0,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.submittedApplication,
    this.errorMessage,
  });

  final FinancialPartnerEntity? selectedPartner;
  final int requestedAmount; // FCFA
  final int durationMonths;
  final LoanPurpose purpose;
  final bool consentSharePassport;
  final int estimatedMonthlyPayment; // FCFA
  final bool isSubmitting;
  final bool isSuccess;
  final LoanApplicationEntity? submittedApplication;
  final String? errorMessage;

  bool get isValid =>
      selectedPartner != null &&
      requestedAmount > 0 &&
      durationMonths > 0 &&
      consentSharePassport;

  LoanApplicationFormState copyWith({
    FinancialPartnerEntity? selectedPartner,
    int? requestedAmount,
    int? durationMonths,
    LoanPurpose? purpose,
    bool? consentSharePassport,
    int? estimatedMonthlyPayment,
    bool? isSubmitting,
    bool? isSuccess,
    LoanApplicationEntity? submittedApplication,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoanApplicationFormState(
      selectedPartner: selectedPartner ?? this.selectedPartner,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      purpose: purpose ?? this.purpose,
      consentSharePassport: consentSharePassport ?? this.consentSharePassport,
      estimatedMonthlyPayment:
          estimatedMonthlyPayment ?? this.estimatedMonthlyPayment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      submittedApplication: submittedApplication ?? this.submittedApplication,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedPartner,
    requestedAmount,
    durationMonths,
    purpose,
    consentSharePassport,
    estimatedMonthlyPayment,
    isSubmitting,
    isSuccess,
    submittedApplication,
    errorMessage,
  ];
}
