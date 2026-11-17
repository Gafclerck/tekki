/// Langue de diffusion de la capsule audio éducative.
///
/// Le Wolof est prioritaire par défaut pour valoriser l'oralité commerçante
/// et la familiarité des termes de gestion au comptoir.
enum AudioLanguage {
  wolof,
  francais;

  String get label => switch (this) {
    AudioLanguage.wolof => 'Wolof',
    AudioLanguage.francais => 'Français',
  };

  String get code => switch (this) {
    AudioLanguage.wolof => 'wo',
    AudioLanguage.francais => 'fr',
  };
}
