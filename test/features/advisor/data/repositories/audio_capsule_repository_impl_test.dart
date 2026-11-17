import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/data/repositories/audio_capsule_repository_impl.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('AudioCapsuleRepositoryImpl', () {
    late MockAudioCapsuleLocalDataSource mockDataSource;
    late AudioCapsuleRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockAudioCapsuleLocalDataSource();
      repository = AudioCapsuleRepositoryImpl(localDataSource: mockDataSource);
    });

    group('getActiveCapsule', () {
      test('returns Success with capsule from local datasource', () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockDataSource.getActiveCapsule(),
        ).thenAnswer((_) async => capsule);

        final result = await repository.getActiveCapsule();

        expect(result.isSuccess, isTrue);
        expect(
          (result as Success<AudioCapsuleEntity, Failure>).data,
          equals(capsule),
        );
        verify(() => mockDataSource.getActiveCapsule()).called(1);
      });

      test('returns Failure when local datasource throws exception', () async {
        when(
          () => mockDataSource.getActiveCapsule(),
        ).thenThrow(Exception('Storage error'));

        final result = await repository.getActiveCapsule();

        expect(result.isError, isTrue);
        expect(
          (result as Error<AudioCapsuleEntity, Failure>).failure,
          isA<AudioFailure>(),
        );
      });
    });

    group('getAllCapsules', () {
      test('returns Success with list of capsules', () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockDataSource.getAllCapsules(),
        ).thenAnswer((_) async => [capsule]);

        final result = await repository.getAllCapsules();

        expect(result.isSuccess, isTrue);
        expect(
          (result as Success<List<AudioCapsuleEntity>, Failure>).data,
          equals([capsule]),
        );
        verify(() => mockDataSource.getAllCapsules()).called(1);
      });

      test('returns Failure when datasource throws', () async {
        when(
          () => mockDataSource.getAllCapsules(),
        ).thenThrow(Exception('Database error'));

        final result = await repository.getAllCapsules();

        expect(result.isError, isTrue);
        expect(
          (result as Error<List<AudioCapsuleEntity>, Failure>).failure,
          isA<AudioFailure>(),
        );
      });
    });
  });
}
