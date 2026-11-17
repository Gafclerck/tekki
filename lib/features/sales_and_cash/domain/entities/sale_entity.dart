import 'package:equatable/equatable.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';

class SaleEntity extends Equatable {
  SaleEntity({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required DateTime recordedAt,
    this.closureId,
    this.syncStatus = 'pending',
    DateTime? lastSyncedAt,
  }) : recordedAt = recordedAt.toUtc(),
       lastSyncedAt = lastSyncedAt?.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError('Sale id cannot be empty');
    }
    if (amount <= 0) {
      throw ArgumentError('Sale amount must be strictly positive');
    }
    if (closureId != null && closureId!.trim().isEmpty) {
      throw ArgumentError('closureId cannot be empty or whitespace');
    }
  }

  const SaleEntity.raw({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.recordedAt,
    this.closureId,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
  });

  final String id;
  final int amount;
  final PaymentMethod paymentMethod;
  final DateTime recordedAt;
  final String? closureId;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  SaleEntity copyWith({
    String? id,
    int? amount,
    PaymentMethod? paymentMethod,
    DateTime? recordedAt,
    String? closureId,
    bool clearClosureId = false,
    String? syncStatus,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedAt: recordedAt ?? this.recordedAt,
      closureId: clearClosureId ? null : (closureId ?? this.closureId),
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: clearLastSyncedAt
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    paymentMethod,
    recordedAt,
    closureId,
    syncStatus,
    lastSyncedAt,
  ];
}
