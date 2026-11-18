import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/features/sync/domain/entities/outbox_event_entity.dart';

class RemoteSyncResponse {
  const RemoteSyncResponse({
    required this.isSuccess,
    this.processedEventIds = const [],
    this.failedEventIds = const [],
    this.errorMessage,
    this.statusCode,
  });

  const RemoteSyncResponse.success({
    required List<String> processedEventIds,
    List<String> failedEventIds = const [],
    int statusCode = 200,
  }) : this(
         isSuccess: true,
         processedEventIds: processedEventIds,
         failedEventIds: failedEventIds,
         statusCode: statusCode,
       );

  const RemoteSyncResponse.failure({
    required String errorMessage,
    int? statusCode,
    List<String> failedEventIds = const [],
  }) : this(
         isSuccess: false,
         errorMessage: errorMessage,
         statusCode: statusCode,
         failedEventIds: failedEventIds,
       );

  final bool isSuccess;
  final List<String> processedEventIds;
  final List<String> failedEventIds;
  final String? errorMessage;
  final int? statusCode;
}

abstract interface class RemoteSyncApiClient {
  Future<RemoteSyncResponse> sendBatch(List<OutboxEventEntity> events);
}

class HttpRemoteSyncApiClient implements RemoteSyncApiClient {
  HttpRemoteSyncApiClient({
    http.Client? client,
    String? endpoint,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _endpoint = endpoint ?? AppConstants.defaultSyncEndpoint;

  final http.Client _client;
  final String _endpoint;
  final Duration timeout;

  @override
  Future<RemoteSyncResponse> sendBatch(List<OutboxEventEntity> events) async {
    if (events.isEmpty) {
      return const RemoteSyncResponse.success(processedEventIds: []);
    }

    try {
      final eventsPayload = events.map((e) {
        dynamic parsedPayload;
        try {
          parsedPayload = jsonDecode(e.payloadJson);
        } catch (_) {
          parsedPayload = e.payloadJson;
        }

        return {
          'client_event_id': e.clientEventId,
          'event_type': e.eventType,
          'target_table': e.targetTable,
          'target_id': e.targetId,
          'payload': parsedPayload,
          'created_at': e.createdAt.toUtc().toIso8601String(),
        };
      }).toList();

      final body = jsonEncode({'events': eventsPayload});

      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Client-Version': AppConstants.appVersion,
            },
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          // If body is empty or non-JSON 200, assume all succeeded
          return RemoteSyncResponse.success(
            processedEventIds: events.map((e) => e.clientEventId).toList(),
            statusCode: response.statusCode,
          );
        }

        final processed =
            (responseData['processed_event_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            events.map((e) => e.clientEventId).toList();

        final failed =
            (responseData['failed_event_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];

        return RemoteSyncResponse.success(
          processedEventIds: processed,
          failedEventIds: failed,
          statusCode: response.statusCode,
        );
      } else {
        return RemoteSyncResponse.failure(
          statusCode: response.statusCode,
          errorMessage:
              'Server responded with status ${response.statusCode}: ${response.body}',
          failedEventIds: events.map((e) => e.clientEventId).toList(),
        );
      }
    } on SocketException catch (e) {
      return RemoteSyncResponse.failure(
        errorMessage: 'Network connection error: ${e.message}',
        failedEventIds: events.map((e) => e.clientEventId).toList(),
      );
    } on TimeoutException {
      return RemoteSyncResponse.failure(
        errorMessage: 'Network timeout connecting to sync server',
        failedEventIds: events.map((e) => e.clientEventId).toList(),
      );
    } catch (e) {
      return RemoteSyncResponse.failure(
        errorMessage: 'Unexpected error during sync batch transmission: $e',
        failedEventIds: events.map((e) => e.clientEventId).toList(),
      );
    }
  }
}
