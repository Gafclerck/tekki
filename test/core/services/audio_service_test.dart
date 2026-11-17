import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/services/audio_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  group('JustAudioPlayerService', () {
    late MockAudioPlayer mockPlayer;
    late JustAudioPlayerService audioService;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      audioService = JustAudioPlayerService(player: mockPlayer);
    });

    test(
      'playCashDrawerSound calls setAsset, seek and play with cash drawer asset',
      () async {
        when(
          () => mockPlayer.setAsset(any()),
        ).thenAnswer((_) async => const Duration(seconds: 1));
        when(() => mockPlayer.seek(any())).thenAnswer((_) async {});
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await audioService.playCashDrawerSound();

        verify(
          () => mockPlayer.setAsset(JustAudioPlayerService.cashDrawerAsset),
        ).called(1);
        verify(() => mockPlayer.seek(Duration.zero)).called(1);
        verify(() => mockPlayer.play()).called(1);
      },
    );

    test(
      'intercepts missing audio asset error silently without rethrowing',
      () async {
        when(
          () => mockPlayer.setAsset(any()),
        ).thenThrow(Exception('Asset not found'));

        // Should complete normally without throwing
        await expectLater(audioService.playCashDrawerSound(), completes);
      },
    );

    test('intercepts playback error silently without rethrowing', () async {
      when(
        () => mockPlayer.setAsset(any()),
      ).thenAnswer((_) async => const Duration(seconds: 1));
      when(() => mockPlayer.seek(any())).thenAnswer((_) async {});
      when(() => mockPlayer.play()).thenThrow(Exception('Native codec error'));

      await expectLater(audioService.playCashDrawerSound(), completes);
    });

    test('dispose calls player dispose', () async {
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      await audioService.dispose();

      verify(() => mockPlayer.dispose()).called(1);
    });
  });
}
