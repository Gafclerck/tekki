import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';
import 'package:tekki/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_state.dart';

/// Cubit pilotant le chargement, la lecture, la bascule bilingue 1-tap,
/// le scrubbing et la mise en pause automatique sur cycle de vie applicatif.
class AudioCapsuleCubit extends Cubit<AudioCapsuleState>
    with WidgetsBindingObserver {
  AudioCapsuleCubit({
    required this.getActiveAudioCapsuleUseCase,
    required this.audioPlayerService,
  }) : super(const AudioCapsuleState()) {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // In pure unit test environments without binding initialized
    }
    _initStreams();
  }

  final GetActiveAudioCapsuleUseCase getActiveAudioCapsuleUseCase;
  final IAudioPlayerService audioPlayerService;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  void _initStreams() {
    _positionSubscription = audioPlayerService.positionStream.listen((pos) {
      if (!isClosed && (state.isPlaying || state.isPaused)) {
        emit(state.copyWith(currentPosition: pos));
      }
    }, onError: (_) {});

    _durationSubscription = audioPlayerService.durationStream.listen((dur) {
      if (!isClosed && dur != null && dur > Duration.zero) {
        emit(state.copyWith(totalDuration: dur));
      }
    }, onError: (_) {});

    _playerStateSubscription = audioPlayerService.playerStateStream.listen((
      playerState,
    ) {
      if (isClosed) return;
      if (playerState.processingState == ProcessingState.completed) {
        try {
          audioPlayerService.seek(Duration.zero);
        } catch (_) {}
        emit(
          state.copyWith(
            playbackStatus: CapsulePlaybackStatus.completed,
            currentPosition: Duration.zero,
          ),
        );
      }
    }, onError: (_) {});
  }

  /// Charge la capsule active et prépare la piste Wolof par défaut.
  Future<void> loadActiveCapsule() async {
    emit(state.copyWith(playbackStatus: CapsulePlaybackStatus.loading));
    final result = await getActiveAudioCapsuleUseCase();

    switch (result) {
      case Success(data: final capsule):
        final totalDuration = Duration(seconds: capsule.durationSeconds);
        emit(
          state.copyWith(
            capsule: capsule,
            selectedLanguage: AudioLanguage.wolof,
            playbackStatus: CapsulePlaybackStatus.idle,
            currentPosition: Duration.zero,
            totalDuration: totalDuration,
            clearError: true,
          ),
        );

        try {
          await audioPlayerService.loadAudio(
            capsule.wolofTrackPath,
            isAsset: capsule.isWolofAsset,
          );
        } catch (_) {}
      case Error(failure: final failure):
        emit(
          state.copyWith(
            playbackStatus: CapsulePlaybackStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }

  /// Démarre ou reprend la lecture de la capsule audio.
  Future<void> play() async {
    final capsule = state.capsule;
    if (capsule == null) {
      await loadActiveCapsule();
      if (state.capsule == null) return;
    }

    try {
      if (state.isPaused) {
        await audioPlayerService.play();
        emit(
          state.copyWith(
            playbackStatus: CapsulePlaybackStatus.playing,
            clearError: true,
          ),
        );
        return;
      }

      if (state.isCompleted) {
        await audioPlayerService.seek(Duration.zero);
        emit(state.copyWith(currentPosition: Duration.zero));
      }

      final activeTrack = state.capsule!.trackPathFor(state.selectedLanguage);
      final isAsset = state.capsule!.isAssetFor(state.selectedLanguage);

      await audioPlayerService.loadAudio(activeTrack, isAsset: isAsset);
      if (state.currentPosition > Duration.zero) {
        await audioPlayerService.seek(state.currentPosition);
      }

      await audioPlayerService.play();
      emit(
        state.copyWith(
          playbackStatus: CapsulePlaybackStatus.playing,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          playbackStatus: CapsulePlaybackStatus.error,
          errorMessage: 'Lecture impossible : $e',
        ),
      );
    }
  }

  /// Met la lecture en pause tout en conservant la position temporelle.
  Future<void> pause() async {
    emit(state.copyWith(playbackStatus: CapsulePlaybackStatus.paused));
    try {
      await audioPlayerService.pause();
    } catch (_) {}
  }

  /// Bascule instantanée entre Lecture et Pause.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Bascule instantanée de langue (Wolof <-> Français) en 1 tap.
  /// Maintient la position temporelle et l'état de lecture actif.
  Future<void> switchLanguage(AudioLanguage newLanguage) async {
    if (newLanguage == state.selectedLanguage) return;

    final wasPlaying = state.isPlaying;
    final currentPos = state.currentPosition;
    final capsule = state.capsule;

    emit(state.copyWith(selectedLanguage: newLanguage));

    if (capsule != null) {
      try {
        final trackPath = capsule.trackPathFor(newLanguage);
        final isAsset = capsule.isAssetFor(newLanguage);

        await audioPlayerService.loadAudio(trackPath, isAsset: isAsset);
        final maxDuration = state.totalDuration;
        final targetPos =
            maxDuration > Duration.zero && currentPos > maxDuration
            ? maxDuration
            : currentPos;
        await audioPlayerService.seek(targetPos);

        if (wasPlaying) {
          await audioPlayerService.play();
          emit(state.copyWith(playbackStatus: CapsulePlaybackStatus.playing));
        }
      } catch (e) {
        // Dégradation silencieuse sans plantage
        emit(
          state.copyWith(
            errorMessage: 'Piste audio bilingue momentanément indisponible.',
          ),
        );
      }
    }
  }

  /// Ajuste la position temporelle de lecture (scrubbing / jauge).
  Future<void> seek(Duration position) async {
    final maxDuration = state.totalDuration;
    final clampedPosition = maxDuration > Duration.zero
        ? (position < Duration.zero
              ? Duration.zero
              : (position > maxDuration ? maxDuration : position))
        : (position < Duration.zero ? Duration.zero : position);

    emit(state.copyWith(currentPosition: clampedPosition));
    try {
      await audioPlayerService.seek(clampedPosition);
    } catch (_) {}
  }

  /// Arrête la lecture et réinitialise la position à zéro.
  Future<void> stop() async {
    emit(
      state.copyWith(
        playbackStatus: CapsulePlaybackStatus.idle,
        currentPosition: Duration.zero,
      ),
    );
    try {
      await audioPlayerService.stop();
    } catch (_) {}
  }

  /// Pause automatique lors de la mise en arrière-plan ou d'un appel entrant.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (isClosed) return;
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      if (state.isPlaying) {
        pause();
      }
    }
  }

  @override
  Future<void> close() async {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    try {
      await audioPlayerService.pause();
    } catch (_) {}
    return super.close();
  }
}
