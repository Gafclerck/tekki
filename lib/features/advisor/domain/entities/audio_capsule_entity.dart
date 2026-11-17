import 'package:equatable/equatable.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';

/// Entité métier immuable représentant une capsule audio éducative scénarisée (Dart pur).
class AudioCapsuleEntity extends Equatable {
  const AudioCapsuleEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
    required this.wolofTrackPath,
    required this.frenchTrackPath,
    this.isWolofAsset = true,
    this.isFrenchAsset = true,
    required this.summary,
  });

  final String id;
  final String title;
  final String category;
  final int durationSeconds;
  final String wolofTrackPath;
  final String frenchTrackPath;
  final bool isWolofAsset;
  final bool isFrenchAsset;
  final String summary;

  /// Retourne le chemin de la piste correspondant à la langue demandée.
  String trackPathFor(AudioLanguage language) => switch (language) {
    AudioLanguage.wolof => wolofTrackPath,
    AudioLanguage.francais => frenchTrackPath,
  };

  /// Indique si la piste est embarquée en asset ou téléchargée dans le cache.
  bool isAssetFor(AudioLanguage language) => switch (language) {
    AudioLanguage.wolof => isWolofAsset,
    AudioLanguage.francais => isFrenchAsset,
  };

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    durationSeconds,
    wolofTrackPath,
    frenchTrackPath,
    isWolofAsset,
    isFrenchAsset,
    summary,
  ];
}
