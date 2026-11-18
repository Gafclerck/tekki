import 'package:equatable/equatable.dart';

class LoanEligibilityEntity extends Equatable {
  const LoanEligibilityEntity({
    required this.isEligible,
    required this.maxBorrowingCapacity,
    required this.currentScore,
    required this.closuresCount,
    required this.grade,
    required this.statusSummary,
    required this.eligiblePartnerIds,
    this.recommendationMessage,
  });

  final bool isEligible;
  final int maxBorrowingCapacity; // in integer FCFA
  final int currentScore; // Tekki Passport score 0-100
  final int closuresCount;
  final String grade; // 'A+', 'A', 'B', 'C'
  final String statusSummary;
  final List<String> eligiblePartnerIds;
  final String? recommendationMessage;

  @override
  List<Object?> get props => [
    isEligible,
    maxBorrowingCapacity,
    currentScore,
    closuresCount,
    grade,
    statusSummary,
    eligiblePartnerIds,
    recommendationMessage,
  ];
}
