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

    test('loadAudio calls setAsset when isAsset is true', () async {
      when(
        () => mockPlayer.setAsset(any()),
      ).thenAnswer((_) async => const Duration(seconds: 35));

      await audioService.loadAudio('assets/audio/test.opus', isAsset: true);

      verify(() => mockPlayer.setAsset('assets/audio/test.opus')).called(1);
    });

    test('loadAudio calls setFilePath when isAsset is false', () async {
      when(
        () => mockPlayer.setFilePath(any()),
      ).thenAnswer((_) async => const Duration(seconds: 40));

      await audioService.loadAudio(
        '/data/user/0/cache/track.opus',
        isAsset: false,
      );

      verify(
        () => mockPlayer.setFilePath('/data/user/0/cache/track.opus'),
      ).called(1);
    });

    test('loadAudio intercepts error gracefully without throwing', () async {
      when(
        () => mockPlayer.setAsset(any()),
      ).thenThrow(Exception('File not found'));

      await expectLater(
        audioService.loadAudio('missing.opus', isAsset: true),
        completes,
      );
    });

    test('play, pause, stop and seek delegate to underlying player', () async {
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.pause()).thenAnswer((_) async {});
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.seek(any())).thenAnswer((_) async {});

      await audioService.play();
      verify(() => mockPlayer.play()).called(1);

      await audioService.pause();
      verify(() => mockPlayer.pause()).called(1);

      await audioService.seek(const Duration(seconds: 15));
      verify(() => mockPlayer.seek(const Duration(seconds: 15))).called(1);

      await audioService.stop();
      verify(() => mockPlayer.stop()).called(1);
      verify(() => mockPlayer.seek(Duration.zero)).called(1);
    });

    test('play, pause, stop and seek intercept errors gracefully', () async {
      when(() => mockPlayer.play()).thenThrow(Exception('Hardware error'));
      when(() => mockPlayer.pause()).thenThrow(Exception('Pause error'));
      when(() => mockPlayer.stop()).thenThrow(Exception('Stop error'));
      when(() => mockPlayer.seek(any())).thenThrow(Exception('Seek error'));

      await expectLater(audioService.play(), completes);
      await expectLater(audioService.pause(), completes);
      await expectLater(audioService.stop(), completes);
      await expectLater(
        audioService.seek(const Duration(seconds: 10)),
        completes,
      );
    });

    test('position, duration, isPlaying getters expose player properties', () {
      when(() => mockPlayer.position).thenReturn(const Duration(seconds: 12));
      when(() => mockPlayer.duration).thenReturn(const Duration(seconds: 35));
      when(() => mockPlayer.playing).thenReturn(true);

      expect(audioService.position, equals(const Duration(seconds: 12)));
      expect(audioService.duration, equals(const Duration(seconds: 35)));
      expect(audioService.isPlaying, isTrue);
    });

    test('streams expose underlying player streams', () {
      when(
        () => mockPlayer.positionStream,
      ).thenAnswer((_) => Stream.value(const Duration(seconds: 5)));
      when(
        () => mockPlayer.durationStream,
      ).thenAnswer((_) => Stream.value(const Duration(seconds: 35)));
      when(() => mockPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(true, ProcessingState.ready)),
      );

      expect(audioService.positionStream, emits(const Duration(seconds: 5)));
      expect(audioService.durationStream, emits(const Duration(seconds: 35)));
      expect(
        audioService.playerStateStream,
        emits(
          isA<PlayerState>()
              .having((s) => s.playing, 'playing', isTrue)
              .having(
                (s) => s.processingState,
                'processingState',
                ProcessingState.ready,
              ),
        ),
      );
    });

    test('dispose calls player dispose', () async {
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      await audioService.dispose();

      verify(() => mockPlayer.dispose()).called(1);
    });

    test(
      'separates SFX player from capsule player when different instances provided',
      () async {
        final mockSfx = MockAudioPlayer();
        final mockCapsule = MockAudioPlayer();
        final dualService = JustAudioPlayerService(
          sfxPlayer: mockSfx,
          capsulePlayer: mockCapsule,
        );

        when(
          () => mockSfx.setAsset(any()),
        ).thenAnswer((_) async => const Duration(seconds: 1));
        when(() => mockSfx.seek(any())).thenAnswer((_) async {});
        when(() => mockSfx.play()).thenAnswer((_) async {});

        when(() => mockCapsule.play()).thenAnswer((_) async {});

        await dualService.playCashDrawerSound();
        verify(() => mockSfx.play()).called(1);
        verifyNever(() => mockCapsule.play());

        await dualService.play();
        verify(() => mockCapsule.play()).called(1);
      },
    );
  });
}
