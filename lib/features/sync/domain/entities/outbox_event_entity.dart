import 'package:equatable/equatable.dart';

class OutboxEventEntity extends Equatable {
  const OutboxEventEntity({
    required this.clientEventId,
    required this.eventType,
    required this.targetTable,
    required this.targetId,
    required this.payloadJson,
    this.retryCount = 0,
    this.status = 'PENDING',
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  final String clientEventId;
  final String eventType;
  final String targetTable;
  final String targetId;
  final String payloadJson;
  final int retryCount;
  final String status;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;

  bool get isPending => status == 'PENDING';
  bool get isSynced => status == 'SYNCED';
  bool get isFailed => status == 'FAILED';

  OutboxEventEntity copyWith({
    String? clientEventId,
    String? eventType,
    String? targetTable,
    String? targetId,
    String? payloadJson,
    int? retryCount,
    String? status,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return OutboxEventEntity(
      clientEventId: clientEventId ?? this.clientEventId,
      eventType: eventType ?? this.eventType,
      targetTable: targetTable ?? this.targetTable,
      targetId: targetId ?? this.targetId,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    clientEventId,
    eventType,
    targetTable,
    targetId,
    payloadJson,
    retryCount,
    status,
    createdAt,
    lastAttemptAt,
    errorMessage,
  ];
}
