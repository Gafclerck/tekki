import 'package:equatable/equatable.dart';

enum PartnerType { microfinance, mesofinance, bank, cooperative }

class FinancialPartnerEntity extends Equatable {
  const FinancialPartnerEntity({
    required this.id,
    required this.name,
    required this.partnerType,
    required this.tagline,
    required this.minAmount,
    required this.maxAmount,
    required this.interestRateMonthly,
    required this.minDurationMonths,
    required this.maxDurationMonths,
    required this.requiredMinScore,
    required this.requiredClosuresCount,
    this.badgeLabel,
    this.contactPhone = '',
    this.contactEmail = '',
    this.processingTimeDays = 2,
  });

  final String id;
  final String name;
  final PartnerType partnerType;
  final String tagline;
  final int minAmount; // in FCFA
  final int maxAmount; // in FCFA
  final double interestRateMonthly; // e.g. 1.8 means 1.8% per month
  final int minDurationMonths;
  final int maxDurationMonths;
  final int requiredMinScore; // Minimum Tekki Passport score required (0-100)
  final int requiredClosuresCount; // Minimum daily closures required
  final String? badgeLabel;
  final String contactPhone;
  final String contactEmail;
  final int processingTimeDays;

  String get typeDisplayName {
    switch (partnerType) {
      case PartnerType.microfinance:
        return 'Microfinance';
      case PartnerType.mesofinance:
        return 'Mésofinance';
      case PartnerType.bank:
        return 'Banque';
      case PartnerType.cooperative:
        return 'Coopérative de crédit';
    }
  }

  /// Calculates estimated monthly payment for a loan amount and duration.
  /// Standard amortized or flat estimation in integer FCFA.
  int calculateEstimatedMonthlyPayment({
    required int amount,
    required int durationMonths,
  }) {
    if (durationMonths <= 0 || amount <= 0) return 0;
    final totalInterest =
        (amount * (interestRateMonthly / 100.0) * durationMonths).round();
    final totalRepayment = amount + totalInterest;
    return (totalRepayment / durationMonths).round();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    partnerType,
    tagline,
    minAmount,
    maxAmount,
    interestRateMonthly,
    minDurationMonths,
    maxDurationMonths,
    requiredMinScore,
    requiredClosuresCount,
    badgeLabel,
    contactPhone,
    contactEmail,
    processingTimeDays,
  ];
}
