import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';
import 'package:tekki/features/advisor/domain/repositories/audio_capsule_repository.dart';

/// Cas d'utilisation pur Dart récupérant la capsule active pour le commerçant.
class GetActiveAudioCapsuleUseCase {
  const GetActiveAudioCapsuleUseCase({required this.repository});

  final AudioCapsuleRepository repository;

  Future<Result<AudioCapsuleEntity, Failure>> call() {
    return repository.getActiveCapsule();
  }
}
