import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/sync/data/datasources/remote_sync_api_client.dart';
import '../../../../helpers/fixtures.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late HttpRemoteSyncApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    apiClient = HttpRemoteSyncApiClient(
      client: mockClient,
      endpoint: 'https://api.tekki.app/v1/sync/batch',
    );
  });

  group('HttpRemoteSyncApiClient Unit Tests', () {
    test(
      'Empty batch returns success immediately without HTTP invocation',
      () async {
        final response = await apiClient.sendBatch([]);
        expect(response.isSuccess, isTrue);
        expect(response.processedEventIds, isEmpty);
        verifyZeroInteractions(mockClient);
      },
    );

    test('HTTP 200 parses processed_event_ids and returns success', () async {
      final event1 = createTestOutboxEvent(clientEventId: 'evt-1');
      final event2 = createTestOutboxEvent(clientEventId: 'evt-2');

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'status': 'success',
            'processed_event_ids': ['evt-1', 'evt-2'],
            'failed_event_ids': <String>[],
          }),
          200,
        ),
      );

      final response = await apiClient.sendBatch([event1, event2]);

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 200);
      expect(response.processedEventIds, ['evt-1', 'evt-2']);
      expect(response.failedEventIds, isEmpty);
    });

    test('HTTP 207 Multi-Status parses processed and failed ids', () async {
      final event1 = createTestOutboxEvent(clientEventId: 'evt-ok');
      final event2 = createTestOutboxEvent(clientEventId: 'evt-fail');

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'status': 'partial',
            'processed_event_ids': ['evt-ok'],
            'failed_event_ids': ['evt-fail'],
          }),
          207,
        ),
      );

      final response = await apiClient.sendBatch([event1, event2]);

      expect(response.isSuccess, isTrue);
      expect(response.processedEventIds, ['evt-ok']);
      expect(response.failedEventIds, ['evt-fail']);
    });

    test('HTTP 500 returns failure with statusCode without throwing', () async {
      final event = createTestOutboxEvent(clientEventId: 'evt-err');

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      final response = await apiClient.sendBatch([event]);

      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 500);
      expect(response.errorMessage, contains('500'));
      expect(response.failedEventIds, ['evt-err']);
    });

    test(
      'SocketException returns failure safely without unhandled crash',
      () async {
        final event = createTestOutboxEvent(clientEventId: 'evt-offline');

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(const SocketException('Failed host lookup'));

        final response = await apiClient.sendBatch([event]);

        expect(response.isSuccess, isFalse);
        expect(response.errorMessage, contains('Failed host lookup'));
        expect(response.failedEventIds, ['evt-offline']);
      },
    );
  });
}
