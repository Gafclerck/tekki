import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Contrat abstrait pour la gestion de la luminosité de l'écran (DIP / LSP).
abstract class IBrightnessService {
  /// Pousse temporairement la luminosité de l'écran à son maximum (1.0).
  Future<void> setMaxBrightness();

  /// Restaure la luminosité initiale de l'écran.
  Future<void> restoreBrightness();
}

/// Implémentation concrète utilisant `package:screen_brightness`.
/// Garantit une tolérance totale aux pannes : toute exception de plateforme,
/// absence de support matériel ou permission refusée est interceptée sans bloquer l'UI.
class ScreenBrightnessService implements IBrightnessService {
  ScreenBrightnessService({ScreenBrightness? screenBrightness})
    : _customBrightness = screenBrightness;

  final ScreenBrightness? _customBrightness;
  ScreenBrightness get _brightness =>
      _customBrightness ?? ScreenBrightness.instance;

  bool _isBoosted = false;

  @override
  Future<void> setMaxBrightness() async {
    try {
      await _brightness.setApplicationScreenBrightness(1.0);
      _isBoosted = true;
    } catch (e) {
      debugPrint('Screen brightness boost intercepted gracefully: $e');
    }
  }

  @override
  Future<void> restoreBrightness() async {
    if (!_isBoosted) return;
    try {
      await _brightness.resetApplicationScreenBrightness();
      _isBoosted = false;
    } catch (e) {
      debugPrint('Screen brightness reset intercepted gracefully: $e');
    }
  }
}
