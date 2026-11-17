import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';

/// Contrat abstrait d'accès aux capsules audio éducatives du Conseiller (Dart pur).
abstract class AudioCapsuleRepository {
  /// Récupère la capsule active pour le commerçant.
  Future<Result<AudioCapsuleEntity, Failure>> getActiveCapsule();

  /// Récupère l'ensemble des capsules audio disponibles (embarquées ou en cache).
  Future<Result<List<AudioCapsuleEntity>, Failure>> getAllCapsules();
}
