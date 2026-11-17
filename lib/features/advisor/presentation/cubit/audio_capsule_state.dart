import 'package:equatable/equatable.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';

/// États immuables du lecteur de capsule audio (`AudioCapsuleState`).
class AudioCapsuleState extends Equatable {
  const AudioCapsuleState({
    this.capsule,
    this.selectedLanguage = AudioLanguage.wolof,
    this.playbackStatus = CapsulePlaybackStatus.idle,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
  });

  /// Capsule audio active sélectionnée.
  final AudioCapsuleEntity? capsule;

  /// Langue active (Wolof par défaut à l'ouverture).
  final AudioLanguage selectedLanguage;

  /// Statut courant de la lecture audio.
  final CapsulePlaybackStatus playbackStatus;

  /// Position temporelle courante de l'écoute.
  final Duration currentPosition;

  /// Durée totale de la capsule audio.
  final Duration totalDuration;

  /// Message d'erreur éventuel sans blocage UI.
  final String? errorMessage;

  bool get isPlaying => playbackStatus == CapsulePlaybackStatus.playing;
  bool get isPaused => playbackStatus == CapsulePlaybackStatus.paused;
  bool get isLoading => playbackStatus == CapsulePlaybackStatus.loading;
  bool get isCompleted => playbackStatus == CapsulePlaybackStatus.completed;

  /// Progression de la jauge entre 0.0 et 1.0.
  double get progress {
    if (totalDuration.inMilliseconds <= 0) return 0.0;
    final p = currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }

  AudioCapsuleState copyWith({
    AudioCapsuleEntity? capsule,
    AudioLanguage? selectedLanguage,
    CapsulePlaybackStatus? playbackStatus,
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AudioCapsuleState(
      capsule: capsule ?? this.capsule,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      playbackStatus: playbackStatus ?? this.playbackStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    capsule,
    selectedLanguage,
    playbackStatus,
    currentPosition,
    totalDuration,
    errorMessage,
  ];
}
