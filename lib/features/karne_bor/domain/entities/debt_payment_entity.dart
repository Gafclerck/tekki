import 'package:equatable/equatable.dart';

/// Entité métier représentant un encaissement ou remboursement de créance client.
///
/// Couche Domain pure Dart, sans dépendance Drift ni Flutter.
class DebtPaymentEntity extends Equatable {
  DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.paymentAmount,
    this.paymentMethod = 'ESPECES',
    this.closureId,
    this.syncStatus = 'pending',
    DateTime? lastSyncedAt,
    DateTime? paidAt,
  }) : lastSyncedAt = lastSyncedAt?.toUtc(),
       paidAt = (paidAt ?? DateTime.now()).toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError('Payment id cannot be empty');
    }
    if (debtId.trim().isEmpty) {
      throw ArgumentError('debtId cannot be empty');
    }
    if (paymentAmount <= 0) {
      throw ArgumentError('paymentAmount must be strictly positive');
    }
    if (closureId != null && closureId!.trim().isEmpty) {
      throw ArgumentError('closureId cannot be empty string when provided');
    }
  }

  const DebtPaymentEntity.raw({
    required this.id,
    required this.debtId,
    required this.paymentAmount,
    this.paymentMethod = 'ESPECES',
    this.closureId,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
    required this.paidAt,
  });

  final String id;
  final String debtId;
  final int paymentAmount;
  final String paymentMethod;
  final String? closureId;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime paidAt;

  DebtPaymentEntity copyWith({
    String? id,
    String? debtId,
    int? paymentAmount,
    String? paymentMethod,
    String? closureId,
    bool clearClosureId = false,
    String? syncStatus,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    DateTime? paidAt,
  }) {
    return DebtPaymentEntity(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      closureId: clearClosureId ? null : (closureId ?? this.closureId),
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: clearLastSyncedAt
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
      paidAt: paidAt ?? this.paidAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    debtId,
    paymentAmount,
    paymentMethod,
    closureId,
    syncStatus,
    lastSyncedAt,
    paidAt,
  ];
}
