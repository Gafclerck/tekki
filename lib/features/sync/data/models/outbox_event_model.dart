import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/sync/domain/entities/outbox_event_entity.dart';

class OutboxEventModel extends OutboxEventEntity {
  const OutboxEventModel({
    required super.clientEventId,
    required super.eventType,
    required super.targetTable,
    required super.targetId,
    required super.payloadJson,
    super.retryCount = 0,
    super.status = 'PENDING',
    required super.createdAt,
    super.lastAttemptAt,
    super.errorMessage,
  });

  factory OutboxEventModel.fromEntity(OutboxEventEntity entity) {
    return OutboxEventModel(
      clientEventId: entity.clientEventId,
      eventType: entity.eventType,
      targetTable: entity.targetTable,
      targetId: entity.targetId,
      payloadJson: entity.payloadJson,
      retryCount: entity.retryCount,
      status: entity.status,
      createdAt: entity.createdAt,
      lastAttemptAt: entity.lastAttemptAt,
      errorMessage: entity.errorMessage,
    );
  }

  factory OutboxEventModel.fromDrift(SyncOutboxEntry row) {
    return OutboxEventModel(
      clientEventId: row.clientEventId,
      eventType: row.eventType,
      targetTable: row.targetTable,
      targetId: row.targetId,
      payloadJson: row.payloadJson,
      retryCount: row.retryCount,
      status: row.status,
      createdAt: DateTime.parse(row.createdAt),
      lastAttemptAt: row.lastAttemptAt != null
          ? DateTime.parse(row.lastAttemptAt!)
          : null,
      errorMessage: row.errorMessage,
    );
  }

  factory OutboxEventModel.fromJson(Map<String, dynamic> json) {
    return OutboxEventModel(
      clientEventId: json['client_event_id'] as String,
      eventType: json['event_type'] as String,
      targetTable: json['target_table'] as String,
      targetId: json['target_id'] as String,
      payloadJson: json['payload_json'] is String
          ? json['payload_json'] as String
          : jsonEncode(json['payload']),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    dynamic payload;
    try {
      payload = jsonDecode(payloadJson);
    } catch (_) {
      payload = payloadJson;
    }

    return {
      'client_event_id': clientEventId,
      'event_type': eventType,
      'target_table': targetTable,
      'target_id': targetId,
      'payload': payload,
      'payload_json': payloadJson,
      'retry_count': retryCount,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'last_attempt_at': lastAttemptAt?.toUtc().toIso8601String(),
      'error_message': errorMessage,
    };
  }

  SyncOutboxCompanion toCompanion() {
    return SyncOutboxCompanion.insert(
      clientEventId: clientEventId,
      eventType: eventType,
      targetTable: targetTable,
      targetId: targetId,
      payloadJson: payloadJson,
      retryCount: Value(retryCount),
      status: Value(status),
      createdAt: createdAt.toUtc().toIso8601String(),
      lastAttemptAt: Value(lastAttemptAt?.toUtc().toIso8601String()),
      errorMessage: Value(errorMessage),
    );
  }
}
