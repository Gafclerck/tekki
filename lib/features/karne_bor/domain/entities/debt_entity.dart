import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

class DebtEntity {
  const DebtEntity({
    required this.id,
    required this.debtorId,
    required this.initialAmount,
    required this.remainingAmount,
    required this.dueDate,
    this.status = DebtStatus.active,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
    required this.createdAt,
    this.debtor,
  });

  final String id;
  final String debtorId;
  final int initialAmount;
  final int remainingAmount;
  final DateTime dueDate;
  final DebtStatus status;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DebtorEntity? debtor;

  bool get isOverdue {
    if (status == DebtStatus.settled) return false;
    if (status == DebtStatus.overdue) return true;
    final now = DateTime.now().toUtc();
    final endOfDueDate = DateTime.utc(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      23,
      59,
      59,
    );
    return now.isAfter(endOfDueDate);
  }

  DebtEntity copyWith({
    String? id,
    String? debtorId,
    int? initialAmount,
    int? remainingAmount,
    DateTime? dueDate,
    DebtStatus? status,
    String? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DebtorEntity? debtor,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      initialAmount: initialAmount ?? this.initialAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      debtor: debtor ?? this.debtor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          debtorId == other.debtorId &&
          initialAmount == other.initialAmount &&
          remainingAmount == other.remainingAmount &&
          dueDate == other.dueDate &&
          status == other.status &&
          syncStatus == other.syncStatus &&
          lastSyncedAt == other.lastSyncedAt &&
          createdAt == other.createdAt &&
          debtor == other.debtor;

  @override
  int get hashCode => Object.hash(
        id,
        debtorId,
        initialAmount,
        remainingAmount,
        dueDate,
        status,
        syncStatus,
        lastSyncedAt,
        createdAt,
        debtor,
      );

  @override
  String toString() {
    return 'DebtEntity(id: $id, debtorId: $debtorId, initial: $initialAmount, remaining: $remainingAmount, due: $dueDate, status: ${status.name}, sync: $syncStatus)';
  }
}
