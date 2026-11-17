import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tekki/core/services/brightness_service.dart';

class MockScreenBrightness extends Mock implements ScreenBrightness {}

void main() {
  late MockScreenBrightness mockBrightness;
  late ScreenBrightnessService service;

  setUp(() {
    mockBrightness = MockScreenBrightness();
    service = ScreenBrightnessService(screenBrightness: mockBrightness);
  });

  group('ScreenBrightnessService Unit Tests', () {
    test('setMaxBrightness sets screen brightness to 1.0', () async {
      when(
        () => mockBrightness.setApplicationScreenBrightness(1.0),
      ).thenAnswer((_) async {});

      await service.setMaxBrightness();

      verify(
        () => mockBrightness.setApplicationScreenBrightness(1.0),
      ).called(1);
    });

    test(
      'setMaxBrightness intercepts platform exception gracefully without rethrowing',
      () async {
        when(
          () => mockBrightness.setApplicationScreenBrightness(1.0),
        ).thenThrow(Exception('Platform unsupported or permission denied'));

        await expectLater(service.setMaxBrightness(), completes);
        verify(
          () => mockBrightness.setApplicationScreenBrightness(1.0),
        ).called(1);
      },
    );

    test('restoreBrightness resets screen brightness when boosted', () async {
      when(
        () => mockBrightness.setApplicationScreenBrightness(1.0),
      ).thenAnswer((_) async {});
      when(
        () => mockBrightness.resetApplicationScreenBrightness(),
      ).thenAnswer((_) async {});

      await service.setMaxBrightness();
      await service.restoreBrightness();

      verify(() => mockBrightness.resetApplicationScreenBrightness()).called(1);
    });

    test(
      'restoreBrightness does not call underlying reset if never boosted',
      () async {
        await service.restoreBrightness();

        verifyNever(() => mockBrightness.resetApplicationScreenBrightness());
      },
    );

    test(
      'restoreBrightness intercepts platform exception gracefully without rethrowing',
      () async {
        when(
          () => mockBrightness.setApplicationScreenBrightness(1.0),
        ).thenAnswer((_) async {});
        when(
          () => mockBrightness.resetApplicationScreenBrightness(),
        ).thenThrow(Exception('Reset failed'));

        await service.setMaxBrightness();
        await expectLater(service.restoreBrightness(), completes);

        verify(
          () => mockBrightness.resetApplicationScreenBrightness(),
        ).called(1);
      },
    );
  });
}
