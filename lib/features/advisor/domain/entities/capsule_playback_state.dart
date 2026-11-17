import 'package:equatable/equatable.dart';

/// Statut d'exécution de la lecture audio d'une capsule.
enum CapsulePlaybackStatus { idle, loading, playing, paused, completed, error }

/// Modèle d'état immuable pur Dart décrivant la progression et l'état de lecture.
class CapsulePlaybackState extends Equatable {
  const CapsulePlaybackState({
    this.status = CapsulePlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  final CapsulePlaybackStatus status;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  bool get isPlaying => status == CapsulePlaybackStatus.playing;
  bool get isPaused => status == CapsulePlaybackStatus.paused;
  bool get isLoading => status == CapsulePlaybackStatus.loading;
  bool get isCompleted => status == CapsulePlaybackStatus.completed;

  /// Progression normalisée entre 0.0 et 1.0.
  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    final p = position.inMilliseconds / duration.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }

  CapsulePlaybackState copyWith({
    CapsulePlaybackStatus? status,
    Duration? position,
    Duration? duration,
    String? errorMessage,
  }) {
    return CapsulePlaybackState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, position, duration, errorMessage];
}
