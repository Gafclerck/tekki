import 'package:equatable/equatable.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

enum QuickSaleStatus { initial, submitting, success, failure }

class QuickSaleState extends Equatable {
  const QuickSaleState({
    this.amount = 0,
    this.paymentMethod = PaymentMethod.especes,
    this.status = QuickSaleStatus.initial,
    this.errorMessage,
    this.createdSale,
  });

  final int amount;
  final PaymentMethod paymentMethod;
  final QuickSaleStatus status;
  final String? errorMessage;
  final SaleEntity? createdSale;

  bool get canSubmit => amount > 0 && status != QuickSaleStatus.submitting;

  QuickSaleState copyWith({
    int? amount,
    PaymentMethod? paymentMethod,
    QuickSaleStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    SaleEntity? createdSale,
  }) {
    return QuickSaleState(
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      createdSale: createdSale ?? this.createdSale,
    );
  }

  @override
  List<Object?> get props => [
    amount,
    paymentMethod,
    status,
    errorMessage,
    createdSale,
  ];
}
