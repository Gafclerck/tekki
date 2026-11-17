import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/audio_capsule_entity.dart';
import 'package:tekki/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('GetActiveAudioCapsuleUseCase', () {
    late MockAudioCapsuleRepository mockRepository;
    late GetActiveAudioCapsuleUseCase useCase;

    setUp(() {
      mockRepository = MockAudioCapsuleRepository();
      useCase = GetActiveAudioCapsuleUseCase(repository: mockRepository);
    });

    test(
      'returns Success with AudioCapsuleEntity when repository returns active capsule',
      () async {
        final capsule = createTestAudioCapsule();
        when(
          () => mockRepository.getActiveCapsule(),
        ).thenAnswer((_) async => Result.success(capsule));

        final result = await useCase();

        expect(result.isSuccess, isTrue);
        expect(
          (result as Success<AudioCapsuleEntity, Failure>).data,
          equals(capsule),
        );
        verify(() => mockRepository.getActiveCapsule()).called(1);
      },
    );

    test('returns Error when repository fails to retrieve capsule', () async {
      const failure = AudioFailure(message: 'Capsule introuvable');
      when(
        () => mockRepository.getActiveCapsule(),
      ).thenAnswer((_) async => Result.failure(failure));

      final result = await useCase();

      expect(result.isError, isTrue);
      expect(
        (result as Error<AudioCapsuleEntity, Failure>).failure,
        equals(failure),
      );
      verify(() => mockRepository.getActiveCapsule()).called(1);
    });
  });
}
