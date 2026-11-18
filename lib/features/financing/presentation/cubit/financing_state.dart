import 'package:equatable/equatable.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';

enum FinancingStatus { initial, loading, loaded, error }

class FinancingState extends Equatable {
  const FinancingState({
    this.status = FinancingStatus.initial,
    this.eligibility,
    this.partners = const [],
    this.applications = const [],
    this.selectedPartner,
    this.errorMessage,
  });

  final FinancingStatus status;
  final LoanEligibilityEntity? eligibility;
  final List<FinancialPartnerEntity> partners;
  final List<LoanApplicationEntity> applications;
  final FinancialPartnerEntity? selectedPartner;
  final String? errorMessage;

  FinancingState copyWith({
    FinancingStatus? status,
    LoanEligibilityEntity? eligibility,
    List<FinancialPartnerEntity>? partners,
    List<LoanApplicationEntity>? applications,
    FinancialPartnerEntity? selectedPartner,
    String? errorMessage,
    bool clearSelectedPartner = false,
  }) {
    return FinancingState(
      status: status ?? this.status,
      eligibility: eligibility ?? this.eligibility,
      partners: partners ?? this.partners,
      applications: applications ?? this.applications,
      selectedPartner: clearSelectedPartner
          ? null
          : (selectedPartner ?? this.selectedPartner),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    eligibility,
    partners,
    applications,
    selectedPartner,
    errorMessage,
  ];
}
