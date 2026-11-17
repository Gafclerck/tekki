import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Abstract contract for audio feedback (DIP / LSP).
abstract class IAudioPlayerService {
  /// Plays the pleasant cash drawer sound when a closure or sale is validated.
  Future<void> playCashDrawerSound();

  /// Plays a custom sound asset.
  Future<void> playSound(String assetPath);

  /// Disposes underlying audio resources.
  Future<void> dispose();
}

/// Concrete audio player using `package:just_audio`.
/// Guarantees 100% fault tolerance: any hardware absence, missing codec,
/// or platform exception is caught silently without failing the transaction.
class JustAudioPlayerService implements IAudioPlayerService {
  JustAudioPlayerService({AudioPlayer? player}) : _customPlayer = player;

  static const String cashDrawerAsset = 'assets/audio/cash_drawer.mp3';

  final AudioPlayer? _customPlayer;
  AudioPlayer? _lazyPlayer;

  AudioPlayer get _player => _customPlayer ?? (_lazyPlayer ??= AudioPlayer());

  @override
  Future<void> playCashDrawerSound() async {
    await playSound(cashDrawerAsset);
  }

  @override
  Future<void> playSound(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      // Graceful degradation: never throw or block UI
      debugPrint('Audio playback error intercepted gracefully: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      if (_customPlayer != null) {
        await _customPlayer.dispose();
      } else if (_lazyPlayer != null) {
        await _lazyPlayer!.dispose();
      }
    } catch (_) {}
  }
}
