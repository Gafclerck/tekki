import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/services/whatsapp_service.dart';

void main() {
  late UrlLauncherWhatsAppService service;

  setUp(() {
    service = const UrlLauncherWhatsAppService();
  });

  group('UrlLauncherWhatsAppService', () {
    group('sanitizePhoneNumber', () {
      test('formats standard 9-digit Senegalese number starting with 7', () {
        expect(service.sanitizePhoneNumber('771234567'), '221771234567');
        expect(service.sanitizePhoneNumber('077 123 45 67'), '221771234567');
        expect(service.sanitizePhoneNumber('78 123 45 67'), '221781234567');
        expect(service.sanitizePhoneNumber('76-123-45-67'), '221761234567');
        expect(service.sanitizePhoneNumber('70.123.45.67'), '221701234567');
        expect(service.sanitizePhoneNumber('75 999 88 77'), '221759998877');
      });

      test('handles numbers already prefixed with +221 or 221', () {
        expect(service.sanitizePhoneNumber('+221 77 123 45 67'), '221771234567');
        expect(service.sanitizePhoneNumber('221771234567'), '221771234567');
        expect(service.sanitizePhoneNumber('00221771234567'), '221771234567');
      });

      test('strips all non-digit characters correctly', () {
        expect(
          service.sanitizePhoneNumber(' (221) 77-123.45/67 '),
          '221771234567',
        );
      });
    });

    group('buildWhatsAppUri', () {
      test('creates universal wa.me URI with sanitized phone and encoded text', () {
        final uri = service.buildWhatsAppUri(
          phoneNumber: '77 123 45 67',
          message: 'Bonjour Modou, petit rappel amical.',
        );

        expect(uri.scheme, 'https');
        expect(uri.host, 'wa.me');
        expect(uri.path, '/221771234567');
        expect(uri.queryParameters['text'], 'Bonjour Modou, petit rappel amical.');
      });
    });

    group('launchWhatsApp', () {
      test('returns true when launchUrl succeeds', () async {
        Uri? capturedUri;
        final mockService = UrlLauncherWhatsAppService(
          launchUrlFn: (uri, {mode}) async {
            capturedUri = uri;
            return true;
          },
        );

        final result = await mockService.launchWhatsApp(
          phoneNumber: '771234567',
          message: 'Jàmm ak jàmm',
        );

        expect(result, isTrue);
        expect(capturedUri?.path, '/221771234567');
      });

      test('returns false when launchUrl returns false (e.g. app missing)', () async {
        final mockService = UrlLauncherWhatsAppService(
          launchUrlFn: (uri, {mode}) async => false,
        );

        final result = await mockService.launchWhatsApp(
          phoneNumber: '771234567',
          message: 'Test',
        );

        expect(result, isFalse);
      });

      test('catches exceptions gracefully and returns false without throwing', () async {
        final mockService = UrlLauncherWhatsAppService(
          launchUrlFn: (uri, {mode}) async => throw Exception('Platform channel error'),
        );

        final result = await mockService.launchWhatsApp(
          phoneNumber: '771234567',
          message: 'Test',
        );

        expect(result, isFalse);
      });
    });
  });
}
