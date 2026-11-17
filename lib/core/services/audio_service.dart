import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Abstract contract for audio playback and audio capsule education (DIP / LSP).
abstract class IAudioPlayerService {
  /// Plays the pleasant cash drawer sound when a closure or sale is validated.
  Future<void> playCashDrawerSound();

  /// Plays a custom sound asset.
  Future<void> playSound(String assetPath);

  /// Loads an audio file from asset or local file storage.
  Future<void> loadAudio(String path, {bool isAsset = true});

  /// Starts or resumes audio playback.
  Future<void> play();

  /// Pauses audio playback.
  Future<void> pause();

  /// Stops audio playback and resets position to zero.
  Future<void> stop();

  /// Seeks to a specific timestamp in the audio.
  Future<void> seek(Duration position);

  /// Stream of current playback position.
  Stream<Duration> get positionStream;

  /// Stream of total track duration (null when unknown or unloaded).
  Stream<Duration?> get durationStream;

  /// Stream of player state (playing, buffering, completed, etc.).
  Stream<PlayerState> get playerStateStream;

  /// Current position of the player.
  Duration get position;

  /// Total duration of current loaded audio, if known.
  Duration? get duration;

  /// Whether audio is actively playing.
  bool get isPlaying;

  /// Disposes underlying audio resources.
  Future<void> dispose();
}

/// Concrete audio player using `package:just_audio`.
/// Guarantees 100% fault tolerance: any hardware absence, missing codec,
/// or platform exception is caught silently without failing the transaction.
class JustAudioPlayerService implements IAudioPlayerService {
  JustAudioPlayerService({
    AudioPlayer? player,
    AudioPlayer? sfxPlayer,
    AudioPlayer? capsulePlayer,
  }) : _customSfxPlayer = sfxPlayer ?? player,
       _customCapsulePlayer = capsulePlayer ?? player;

  static const String cashDrawerAsset = 'assets/audio/cash_drawer.mp3';

  final AudioPlayer? _customSfxPlayer;
  final AudioPlayer? _customCapsulePlayer;

  AudioPlayer? _lazySfxPlayer;
  AudioPlayer? _lazyCapsulePlayer;

  AudioPlayer get _sfxPlayer =>
      _customSfxPlayer ?? (_lazySfxPlayer ??= AudioPlayer());
  AudioPlayer get _capsulePlayer =>
      _customCapsulePlayer ?? (_lazyCapsulePlayer ??= AudioPlayer());

  @override
  Future<void> playCashDrawerSound() async {
    await playSound(cashDrawerAsset);
  }

  @override
  Future<void> playSound(String assetPath) async {
    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (e) {
      // Graceful degradation: never throw or block UI
      debugPrint('Audio playback error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> loadAudio(String path, {bool isAsset = true}) async {
    try {
      if (isAsset) {
        await _capsulePlayer.setAsset(path);
      } else {
        await _capsulePlayer.setFilePath(path);
      }
    } catch (e) {
      debugPrint('Audio load error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await _capsulePlayer.play();
    } catch (e) {
      debugPrint('Audio play error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _capsulePlayer.pause();
    } catch (e) {
      debugPrint('Audio pause error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _capsulePlayer.stop();
      await _capsulePlayer.seek(Duration.zero);
    } catch (e) {
      debugPrint('Audio stop error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _capsulePlayer.seek(position);
    } catch (e) {
      debugPrint('Audio seek error intercepted gracefully: $e');
    }
  }

  @override
  Stream<Duration> get positionStream {
    try {
      return _capsulePlayer.positionStream;
    } catch (e) {
      debugPrint('Audio positionStream error intercepted gracefully: $e');
      return const Stream.empty();
    }
  }

  @override
  Stream<Duration?> get durationStream {
    try {
      return _capsulePlayer.durationStream;
    } catch (e) {
      debugPrint('Audio durationStream error intercepted gracefully: $e');
      return const Stream.empty();
    }
  }

  @override
  Stream<PlayerState> get playerStateStream {
    try {
      return _capsulePlayer.playerStateStream;
    } catch (e) {
      debugPrint('Audio playerStateStream error intercepted gracefully: $e');
      return const Stream.empty();
    }
  }

  @override
  Duration get position {
    try {
      return _capsulePlayer.position;
    } catch (_) {
      return Duration.zero;
    }
  }

  @override
  Duration? get duration {
    try {
      return _capsulePlayer.duration;
    } catch (_) {
      return null;
    }
  }

  @override
  bool get isPlaying {
    try {
      return _capsulePlayer.playing;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    final playersToDispose = <AudioPlayer>{
      ?_customSfxPlayer,
      ?_customCapsulePlayer,
      ?_lazySfxPlayer,
      ?_lazyCapsulePlayer,
    };
    for (final player in playersToDispose) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }
}
