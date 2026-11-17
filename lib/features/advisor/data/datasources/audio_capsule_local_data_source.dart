import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';

/// Contrat de la source de données locale pour les capsules audio.
abstract class AudioCapsuleLocalDataSource {
  /// Retourne la capsule audio active (par défaut la capsule d'accueil embarquée).
  Future<AudioCapsuleEntity> getActiveCapsule();

  /// Retourne toutes les capsules audio disponibles localement.
  Future<List<AudioCapsuleEntity>> getAllCapsules();
}

/// Implémentation locale fournissant les capsules pré-enregistrées embarquées dans l'APK.
class AudioCapsuleLocalDataSourceImpl implements AudioCapsuleLocalDataSource {
  const AudioCapsuleLocalDataSourceImpl();

  /// Capsule d'accueil embarquée dans l'APK (zéro réseau requis).
  static const AudioCapsuleEntity welcomeCapsule = AudioCapsuleEntity(
    id: 'capsule_welcome',
    title: 'Gérer sa caisse au quotidien',
    category: 'Gestion de caisse',
    durationSeconds: 35,
    wolofTrackPath: 'assets/audio/capsule_welcome_wo.opus',
    frenchTrackPath: 'assets/audio/capsule_welcome_fr.opus',
    isWolofAsset: true,
    isFrenchAsset: true,
    summary:
        'Conseils pratiques en Wolof et Français pour clôturer sa caisse chaque soir sans stress.',
  );

  @override
  Future<AudioCapsuleEntity> getActiveCapsule() async {
    return welcomeCapsule;
  }

  @override
  Future<List<AudioCapsuleEntity>> getAllCapsules() async {
    return const [welcomeCapsule];
  }
}
