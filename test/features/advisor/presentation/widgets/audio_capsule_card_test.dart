import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_state.dart';
import 'package:tekki/features/advisor/presentation/widgets/audio_capsule_card.dart';
import 'package:tekki/injection_container.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AudioLanguage.wolof);
  });

  group('AudioCapsuleCard Widget Tests', () {
    late MockAudioCapsuleCubit mockCubit;

    setUp(() async {
      mockCubit = MockAudioCapsuleCubit();
      if (sl.isRegistered<AudioCapsuleCubit>()) {
        await sl.unregister<AudioCapsuleCubit>();
      }
      addTearDown(() async {
        await sl.reset();
      });
    });

    Widget buildSubject({AudioCapsuleCubit? customCubit}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: customCubit != null
                ? AudioCapsuleCard(cubit: customCubit)
                : const AudioCapsuleCard(),
          ),
        ),
      );
    }

    testWidgets('renders all visual elements with correct styling and borders', (
      tester,
    ) async {
      final capsule = createTestAudioCapsule(
        title: 'Conseil Caisse : Bien clôturer',
        summary:
            'Conseils pratiques en Wolof et Français pour clôturer sa caisse.',
        durationSeconds: 35,
      );

      when(() => mockCubit.state).thenReturn(
        AudioCapsuleState(
          capsule: capsule,
          selectedLanguage: AudioLanguage.wolof,
          playbackStatus: CapsulePlaybackStatus.idle,
          currentPosition: const Duration(seconds: 10),
          totalDuration: const Duration(seconds: 35),
        ),
      );

      await tester.pumpWidget(buildSubject(customCubit: mockCubit));

      // Card exists and has a clean, professional perimeter border
      final cardFinder = find.byKey(const ValueKey('audio_capsule_card'));
      expect(cardFinder, findsOneWidget);
      final cardContainer = tester.widget<Container>(cardFinder);
      final cardDecoration = cardContainer.decoration as BoxDecoration;
      final cardBorder = cardDecoration.border as Border;
      expect(cardBorder.isUniform, isTrue);

      final innerFinder = find.byKey(
        const ValueKey('audio_capsule_card_inner'),
      );
      expect(innerFinder, findsOneWidget);

      // Titles and summaries
      expect(find.text('CAPSULE CONSEIL'), findsOneWidget);
      expect(find.text('Conseil Caisse : Bien clôturer'), findsOneWidget);
      expect(
        find.text(
          'Conseils pratiques en Wolof et Français pour clôturer sa caisse.',
        ),
        findsOneWidget,
      );

      // Bilingue toggle buttons
      expect(find.text('Wolof'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);

      // Language toggle touch target >= 48dp on both axes
      final wolofSize = tester.getSize(
        find.byKey(const ValueKey('audio_lang_wolof')),
      );
      expect(wolofSize.width, greaterThanOrEqualTo(48.0));
      expect(wolofSize.height, greaterThanOrEqualTo(48.0));

      final francaisSize = tester.getSize(
        find.byKey(const ValueKey('audio_lang_francais')),
      );
      expect(francaisSize.width, greaterThanOrEqualTo(48.0));
      expect(francaisSize.height, greaterThanOrEqualTo(48.0));

      // Play/Pause button
      expect(
        find.byKey(const ValueKey('audio_capsule_play_pause_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Touch target >= 48dp
      final buttonSize = tester.getSize(
        find.byKey(const ValueKey('audio_capsule_play_pause_button')),
      );
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      // Ensure NO ElevatedButton is used for Play/Pause (Strict single CTA rule)
      expect(
        find.descendant(of: cardFinder, matching: find.byType(ElevatedButton)),
        findsNothing,
      );

      // Progress bar & timing
      expect(
        find.byKey(const ValueKey('audio_capsule_progress_bar')),
        findsOneWidget,
      );
      expect(find.text('00:10'), findsOneWidget);
      expect(find.text('00:35'), findsOneWidget);
    });

    testWidgets('tapping play button calls togglePlayPause', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AudioCapsuleState(
          capsule: createTestAudioCapsule(),
          selectedLanguage: AudioLanguage.wolof,
          playbackStatus: CapsulePlaybackStatus.idle,
        ),
      );
      when(() => mockCubit.togglePlayPause()).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(customCubit: mockCubit));

      await tester.tap(
        find.byKey(const ValueKey('audio_capsule_play_pause_button')),
      );
      await tester.pump();

      verify(() => mockCubit.togglePlayPause()).called(1);
    });

    testWidgets('displays pause icon when state is playing', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AudioCapsuleState(
          capsule: createTestAudioCapsule(),
          selectedLanguage: AudioLanguage.wolof,
          playbackStatus: CapsulePlaybackStatus.playing,
        ),
      );

      await tester.pumpWidget(buildSubject(customCubit: mockCubit));

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('tapping Français switches language via switchLanguage', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AudioCapsuleState(
          capsule: createTestAudioCapsule(),
          selectedLanguage: AudioLanguage.wolof,
        ),
      );
      when(
        () => mockCubit.switchLanguage(AudioLanguage.francais),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(customCubit: mockCubit));

      await tester.tap(find.byKey(const ValueKey('audio_lang_francais')));
      await tester.pump();

      verify(() => mockCubit.switchLanguage(AudioLanguage.francais)).called(1);
    });

    testWidgets('displays discreet error banner when errorMessage is present', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AudioCapsuleState(
          capsule: createTestAudioCapsule(),
          errorMessage: 'Piste audio momentanément indisponible.',
        ),
      );

      await tester.pumpWidget(buildSubject(customCubit: mockCubit));

      expect(
        find.byKey(const ValueKey('audio_capsule_error_message')),
        findsOneWidget,
      );
      expect(
        find.text('Piste audio momentanément indisponible.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'resolves AudioCapsuleCubit from GetIt when used as const AudioCapsuleCard()',
      (tester) async {
        final capsule = createTestAudioCapsule();
        when(() => mockCubit.state).thenReturn(
          AudioCapsuleState(
            capsule: capsule,
            selectedLanguage: AudioLanguage.wolof,
            playbackStatus: CapsulePlaybackStatus.idle,
          ),
        );

        if (sl.isRegistered<AudioCapsuleCubit>()) {
          await sl.unregister<AudioCapsuleCubit>();
        }
        sl.registerLazySingleton<AudioCapsuleCubit>(() => mockCubit);

        await tester.pumpWidget(buildSubject());

        expect(
          find.byKey(const ValueKey('audio_capsule_card')),
          findsOneWidget,
        );
        expect(find.text(capsule.title), findsOneWidget);
      },
    );
  });
}
