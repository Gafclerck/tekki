import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/data/datasources/audio_capsule_local_data_source.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';
import 'package:tekki/features/advisor/domain/repositories/audio_capsule_repository.dart';

/// Implémentation du repository de capsules audio de la couche Data.
class AudioCapsuleRepositoryImpl implements AudioCapsuleRepository {
  const AudioCapsuleRepositoryImpl({required this.localDataSource});

  final AudioCapsuleLocalDataSource localDataSource;

  @override
  Future<Result<AudioCapsuleEntity, Failure>> getActiveCapsule() async {
    try {
      final capsule = await localDataSource.getActiveCapsule();
      return Result.success(capsule);
    } catch (e) {
      return Result.failure(
        AudioFailure(
          message: 'Impossible de charger la capsule audio active : $e',
        ),
      );
    }
  }

  @override
  Future<Result<List<AudioCapsuleEntity>, Failure>> getAllCapsules() async {
    try {
      final capsules = await localDataSource.getAllCapsules();
      return Result.success(capsules);
    } catch (e) {
      return Result.failure(
        AudioFailure(
          message: 'Impossible de récupérer la liste des capsules audio : $e',
        ),
      );
    }
  }
}
