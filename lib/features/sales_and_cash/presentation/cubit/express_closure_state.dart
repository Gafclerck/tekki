import 'package:equatable/equatable.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';

enum ExpressClosureStatus {
  initial,
  loadingPrefill,
  ready,
  submitting,
  success,
  failure,
}

class ExpressClosureState extends Equatable {
  const ExpressClosureState({
    required this.cutoffTimestamp,
    this.status = ExpressClosureStatus.initial,
    this.prefilledSalesAmount = 0,
    this.totalSalesAmount = 0,
    this.totalExpensesAmount = 0,
    this.cashCounted = 0,
    this.currentStep = 1,
    this.errorMessage,
    this.createdClosure,
    this.activeStreak = 0,
    this.monthlyClosuresCount = 0,
  });

  factory ExpressClosureState.initial([DateTime? cutoffTimestamp]) {
    return ExpressClosureState(
      cutoffTimestamp: (cutoffTimestamp ?? DateTime.now()).toUtc(),
      status: ExpressClosureStatus.initial,
      activeStreak: 0,
      monthlyClosuresCount: 0,
    );
  }

  final DateTime cutoffTimestamp;
  final ExpressClosureStatus status;
  final int prefilledSalesAmount;
  final int totalSalesAmount;
  final int totalExpensesAmount;
  final int cashCounted;
  final int currentStep;
  final String? errorMessage;
  final DailyClosureEntity? createdClosure;
  final int activeStreak;
  final int monthlyClosuresCount;

  /// Passive GPS integrity status from the sealed closure.
  bool? get isLocationFlagged => createdClosure?.isFlaggedLocation;

  int get theoreticalCash => totalSalesAmount - totalExpensesAmount;

  int get difference => cashCounted - theoreticalCash;

  bool get canSubmit =>
      status == ExpressClosureStatus.ready &&
      errorMessage == null &&
      totalSalesAmount >= 0 &&
      totalExpensesAmount >= 0 &&
      cashCounted >= 0;

  ExpressClosureState copyWith({
    DateTime? cutoffTimestamp,
    ExpressClosureStatus? status,
    int? prefilledSalesAmount,
    int? totalSalesAmount,
    int? totalExpensesAmount,
    int? cashCounted,
    int? currentStep,
    String? errorMessage,
    bool clearErrorMessage = false,
    DailyClosureEntity? createdClosure,
    int? activeStreak,
    int? monthlyClosuresCount,
  }) {
    return ExpressClosureState(
      cutoffTimestamp: cutoffTimestamp ?? this.cutoffTimestamp,
      status: status ?? this.status,
      prefilledSalesAmount: prefilledSalesAmount ?? this.prefilledSalesAmount,
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      totalExpensesAmount: totalExpensesAmount ?? this.totalExpensesAmount,
      cashCounted: cashCounted ?? this.cashCounted,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      createdClosure: createdClosure ?? this.createdClosure,
      activeStreak: activeStreak ?? this.activeStreak,
      monthlyClosuresCount: monthlyClosuresCount ?? this.monthlyClosuresCount,
    );
  }

  @override
  List<Object?> get props => [
    cutoffTimestamp,
    status,
    prefilledSalesAmount,
    totalSalesAmount,
    totalExpensesAmount,
    cashCounted,
    currentStep,
    errorMessage,
    createdClosure,
    activeStreak,
    monthlyClosuresCount,
  ];
}
