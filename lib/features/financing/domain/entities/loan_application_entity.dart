import 'package:equatable/equatable.dart';

enum LoanPurpose {
  stock, // Stock & réassort
  equipment, // Équipement & matériel
  treasury, // Trésorerie urgente
  expansion, // Agrandissement & nouveau point de vente
}

extension LoanPurposeX on LoanPurpose {
  String get displayName {
    switch (this) {
      case LoanPurpose.stock:
        return 'Stock & Réassort';
      case LoanPurpose.equipment:
        return 'Équipement & Matériel';
      case LoanPurpose.treasury:
        return 'Trésorerie d\'urgence';
      case LoanPurpose.expansion:
        return 'Agrandissement de la boutique';
    }
  }

  static LoanPurpose fromString(String val) {
    switch (val.toLowerCase()) {
      case 'equipment':
        return LoanPurpose.equipment;
      case 'treasury':
        return LoanPurpose.treasury;
      case 'expansion':
        return LoanPurpose.expansion;
      case 'stock':
      default:
        return LoanPurpose.stock;
    }
  }
}

enum LoanStatus {
  pending, // Déposé, en attente de transmission
  underReview, // En cours d'étude par le partenaire
  approved, // Approuvé
  disbursed, // Fonds décaissés
  rejected, // Rejeté
}

extension LoanStatusX on LoanStatus {
  String get displayName {
    switch (this) {
      case LoanStatus.pending:
        return 'En attente';
      case LoanStatus.underReview:
        return 'En cours d\'étude';
      case LoanStatus.approved:
        return 'Approuvé';
      case LoanStatus.disbursed:
        return 'Décaissé';
      case LoanStatus.rejected:
        return 'Non retenu';
    }
  }

  static LoanStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'UNDER_REVIEW':
      case 'UNDERREVIEW':
        return LoanStatus.underReview;
      case 'APPROVED':
        return LoanStatus.approved;
      case 'DISBURSED':
        return LoanStatus.disbursed;
      case 'REJECTED':
        return LoanStatus.rejected;
      case 'PENDING':
      default:
        return LoanStatus.pending;
    }
  }
}

class LoanApplicationEntity extends Equatable {
  const LoanApplicationEntity({
    required this.id,
    required this.shopId,
    required this.partnerId,
    required this.partnerName,
    required this.requestedAmount,
    required this.durationMonths,
    required this.monthlyPaymentEstimate,
    required this.purpose,
    required this.status,
    required this.submissionDate,
    this.passportScoreAtSubmission = 0,
    this.decisionNotes,
    this.createdAt,
  });

  final String id;
  final String shopId;
  final String partnerId;
  final String partnerName;
  final int requestedAmount; // FCFA
  final int durationMonths;
  final int monthlyPaymentEstimate; // FCFA
  final LoanPurpose purpose;
  final LoanStatus status;
  final DateTime submissionDate;
  final int passportScoreAtSubmission;
  final String? decisionNotes;
  final DateTime? createdAt;

  LoanApplicationEntity copyWith({
    String? id,
    String? shopId,
    String? partnerId,
    String? partnerName,
    int? requestedAmount,
    int? durationMonths,
    int? monthlyPaymentEstimate,
    LoanPurpose? purpose,
    LoanStatus? status,
    DateTime? submissionDate,
    int? passportScoreAtSubmission,
    String? decisionNotes,
    DateTime? createdAt,
  }) {
    return LoanApplicationEntity(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      monthlyPaymentEstimate:
          monthlyPaymentEstimate ?? this.monthlyPaymentEstimate,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      submissionDate: submissionDate ?? this.submissionDate,
      passportScoreAtSubmission:
          passportScoreAtSubmission ?? this.passportScoreAtSubmission,
      decisionNotes: decisionNotes ?? this.decisionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shopId,
    partnerId,
    partnerName,
    requestedAmount,
    durationMonths,
    monthlyPaymentEstimate,
    purpose,
    status,
    submissionDate,
    passportScoreAtSubmission,
    decisionNotes,
    createdAt,
  ];
}
