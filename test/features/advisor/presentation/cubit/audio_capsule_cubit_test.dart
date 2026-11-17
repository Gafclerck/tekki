import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  group('AudioCapsuleCubit', () {
    late MockGetActiveAudioCapsuleUseCase mockUseCase;
    late MockAudioPlayerService mockAudioService;
    late StreamController<Duration> positionController;
    late StreamController<Duration?> durationController;
    late StreamController<PlayerState> playerStateController;
    late AudioCapsuleCubit cubit;

    setUp(() {
      mockUseCase = MockGetActiveAudioCapsuleUseCase();
      mockAudioService = MockAudioPlayerService();
      positionController = StreamController<Duration>.broadcast();
      durationController = StreamController<Duration?>.broadcast();
      playerStateController = StreamController<PlayerState>.broadcast();

      when(
        () => mockAudioService.positionStream,
      ).thenAnswer((_) => positionController.stream);
      when(
        () => mockAudioService.durationStream,
      ).thenAnswer((_) => durationController.stream);
      when(
        () => mockAudioService.playerStateStream,
      ).thenAnswer((_) => playerStateController.stream);
      when(
        () => mockAudioService.loadAudio(any(), isAsset: any(named: 'isAsset')),
      ).thenAnswer((_) async {});
      when(() => mockAudioService.play()).thenAnswer((_) async {});
      when(() => mockAudioService.pause()).thenAnswer((_) async {});
      when(() => mockAudioService.stop()).thenAnswer((_) async {});
      when(() => mockAudioService.seek(any())).thenAnswer((_) async {});

      cubit = AudioCapsuleCubit(
        getActiveAudioCapsuleUseCase: mockUseCase,
        audioPlayerService: mockAudioService,
      );
    });

    tearDown(() async {
      await cubit.close();
      await positionController.close();
      await durationController.close();
      await playerStateController.close();
    });

    test('initial state has default Wolof language and idle status', () {
      expect(cubit.state.selectedLanguage, equals(AudioLanguage.wolof));
      expect(cubit.state.playbackStatus, equals(CapsulePlaybackStatus.idle));
      expect(cubit.state.currentPosition, equals(Duration.zero));
      expect(cubit.state.capsule, isNull);
    });

    test(
      'loadActiveCapsule loads capsule and initializes totalDuration and Wolof asset',
      () async {
        final capsule = createTestAudioCapsule(durationSeconds: 35);
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));

        await cubit.loadActiveCapsule();

        expect(cubit.state.capsule, equals(capsule));
        expect(cubit.state.totalDuration, equals(const Duration(seconds: 35)));
        expect(cubit.state.selectedLanguage, equals(AudioLanguage.wolof));
        expect(cubit.state.playbackStatus, equals(CapsulePlaybackStatus.idle));
        verify(
          () =>
              mockAudioService.loadAudio(capsule.wolofTrackPath, isAsset: true),
        ).called(1);
      },
    );

    test('loadActiveCapsule emits error state on failure', () async {
      when(() => mockUseCase()).thenAnswer(
        (_) async => Result.failure<AudioCapsuleEntity, Failure>(
          const AudioFailure(message: 'Fichier introuvable'),
        ),
      );

      await cubit.loadActiveCapsule();

      expect(cubit.state.playbackStatus, equals(CapsulePlaybackStatus.error));
      expect(cubit.state.errorMessage, equals('Fichier introuvable'));
    });

    test(
      'play and pause toggle playbackStatus and delegate to service',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();

        await cubit.play();
        expect(cubit.state.isPlaying, isTrue);
        expect(
          cubit.state.playbackStatus,
          equals(CapsulePlaybackStatus.playing),
        );
        verify(() => mockAudioService.play()).called(1);

        await cubit.pause();
        expect(cubit.state.isPaused, isTrue);
        expect(
          cubit.state.playbackStatus,
          equals(CapsulePlaybackStatus.paused),
        );
        verify(() => mockAudioService.pause()).called(1);

        await cubit.togglePlayPause();
        expect(cubit.state.isPlaying, isTrue);
      },
    );

    test(
      'play when paused resumes directly without reloading audio source',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();
        await cubit.play();
        await cubit.pause();
        expect(cubit.state.isPaused, isTrue);

        clearInteractions(mockAudioService);

        await cubit.play();

        expect(cubit.state.isPlaying, isTrue);
        verify(() => mockAudioService.play()).called(1);
        verifyNever(
          () =>
              mockAudioService.loadAudio(any(), isAsset: any(named: 'isAsset')),
        );
      },
    );

    test(
      'switchLanguage switches audio track and clamps target position to track duration',
      () async {
        final capsule = createTestAudioCapsule(durationSeconds: 30);
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();
        await cubit.play();
        await cubit.seek(const Duration(seconds: 15));

        // Switch to French while playing at 15s
        await cubit.switchLanguage(AudioLanguage.francais);

        expect(cubit.state.selectedLanguage, equals(AudioLanguage.francais));
        expect(cubit.state.isPlaying, isTrue);
        verify(
          () => mockAudioService.loadAudio(
            capsule.frenchTrackPath,
            isAsset: true,
          ),
        ).called(1);
        verify(
          () => mockAudioService.seek(const Duration(seconds: 15)),
        ).called(2);
      },
    );

    test(
      'didChangeAppLifecycleState pauses audio when app is paused or inactive',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();
        await cubit.play();
        expect(cubit.state.isPlaying, isTrue);

        // Incoming call / Background event
        cubit.didChangeAppLifecycleState(AppLifecycleState.paused);
        expect(cubit.state.isPaused, isTrue);
        verify(() => mockAudioService.pause()).called(1);

        // Play again and trigger inactive
        await cubit.play();
        expect(cubit.state.isPlaying, isTrue);
        cubit.didChangeAppLifecycleState(AppLifecycleState.inactive);
        expect(cubit.state.isPaused, isTrue);
      },
    );

    test(
      'didChangeAppLifecycleState ignores events when cubit is already closed',
      () async {
        await cubit.close();
        expect(
          () => cubit.didChangeAppLifecycleState(AppLifecycleState.paused),
          returnsNormally,
        );
      },
    );

    test(
      'seek clamps position between Duration.zero and totalDuration',
      () async {
        final capsule = createTestAudioCapsule(durationSeconds: 35);
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();

        // Normal seek
        await cubit.seek(const Duration(seconds: 22));
        expect(
          cubit.state.currentPosition,
          equals(const Duration(seconds: 22)),
        );
        verify(
          () => mockAudioService.seek(const Duration(seconds: 22)),
        ).called(1);

        // Beyond totalDuration -> clamps to 35s
        await cubit.seek(const Duration(seconds: 50));
        expect(
          cubit.state.currentPosition,
          equals(const Duration(seconds: 35)),
        );
        verify(
          () => mockAudioService.seek(const Duration(seconds: 35)),
        ).called(1);

        // Negative duration -> clamps to zero
        await cubit.seek(const Duration(seconds: -10));
        expect(cubit.state.currentPosition, equals(Duration.zero));
        verify(() => mockAudioService.seek(Duration.zero)).called(1);
      },
    );

    test(
      'positionStream ticks update currentPosition during playback',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();
        await cubit.play();

        positionController.add(const Duration(seconds: 7));
        await pumpEventQueue();

        expect(cubit.state.currentPosition, equals(const Duration(seconds: 7)));
      },
    );

    test('durationStream updates totalDuration when valid', () async {
      final capsule = createTestAudioCapsule();
      when(
        () => mockUseCase(),
      ).thenAnswer((_) async => Result.success(capsule));
      await cubit.loadActiveCapsule();

      durationController.add(const Duration(seconds: 42));
      await pumpEventQueue();

      expect(cubit.state.totalDuration, equals(const Duration(seconds: 42)));
    });

    test(
      'playerStateStream completed state resets currentPosition to zero and rewinds audio service',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockUseCase(),
        ).thenAnswer((_) async => Result.success(capsule));
        await cubit.loadActiveCapsule();
        await cubit.play();

        playerStateController.add(
          PlayerState(false, ProcessingState.completed),
        );
        await pumpEventQueue();

        expect(
          cubit.state.playbackStatus,
          equals(CapsulePlaybackStatus.completed),
        );
        expect(cubit.state.currentPosition, equals(Duration.zero));
        verify(() => mockAudioService.seek(Duration.zero)).called(1);
      },
    );

    test('stop resets position to zero and status to idle', () async {
      final capsule = createTestAudioCapsule();
      when(
        () => mockUseCase(),
      ).thenAnswer((_) async => Result.success(capsule));
      await cubit.loadActiveCapsule();
      await cubit.play();

      await cubit.stop();
      expect(cubit.state.playbackStatus, equals(CapsulePlaybackStatus.idle));
      expect(cubit.state.currentPosition, equals(Duration.zero));
      verify(() => mockAudioService.stop()).called(1);
    });
  });
}
