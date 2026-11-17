import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';
import 'package:tekki/features/advisor/domain/entities/health_status.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_state.dart';
import 'package:tekki/features/advisor/presentation/pages/advisor_page.dart';
import 'package:tekki/features/advisor/presentation/widgets/advisor_health_badge.dart';
import 'package:tekki/features/advisor/presentation/widgets/audio_capsule_card.dart';
import 'package:tekki/features/advisor/presentation/widgets/health_traffic_light_card.dart';
import 'package:tekki/injection_container.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAdvisorCubit mockCubit;
  late MockAudioCapsuleCubit mockAudioCapsuleCubit;

  setUp(() {
    mockCubit = MockAdvisorCubit();
    mockAudioCapsuleCubit = MockAudioCapsuleCubit();

    when(() => mockAudioCapsuleCubit.state).thenReturn(
      AudioCapsuleState(
        capsule: createTestAudioCapsule(),
        selectedLanguage: AudioLanguage.wolof,
        playbackStatus: CapsulePlaybackStatus.idle,
      ),
    );

    sl.registerLazySingleton<AudioCapsuleCubit>(() => mockAudioCapsuleCubit);

    addTearDown(() async {
      await sl.reset();
    });
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AdvisorCubit>.value(
        value: mockCubit,
        child: const AdvisorPage(),
      ),
    );
  }

  group('AdvisorPage Widget Tests', () {
    testWidgets('renders CircularProgressIndicator when loading', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const AdvisorLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const ValueKey('advisor_page')), findsOneWidget);
    });

    testWidgets('renders error message and retry button when state is Error', (
      tester,
    ) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const AdvisorError(message: 'Erreur réseau simulée'));
      when(() => mockCubit.loadFinancialHealth()).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.text('Erreur réseau simulée'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);

      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      verify(() => mockCubit.loadFinancialHealth()).called(1);
    });

    testWidgets(
      'renders complete financial health diagnostic when state is Loaded',
      (tester) async {
        final health = createTestFinancialHealth(
          overallStatus: HealthStatus.conforme,
          summary: 'Bravo ! Votre boutique se porte très bien.',
          indicators: [
            createTestHealthIndicator(
              id: 'caisse_regularity',
              title: 'Régularité de caisse',
              status: HealthStatus.conforme,
              diagnostic: 'Clôtures quotidiennes exemplaires.',
              recommendation: 'Continuez ainsi ce soir.',
            ),
            createTestHealthIndicator(
              id: 'karne_bor_recovery',
              title: 'Recouvrement Karné Bor',
              status: HealthStatus.attention,
              diagnostic: 'Deux dettes approchent du délai maximum.',
              recommendation: 'Envoyez un rappel amical sur WhatsApp.',
            ),
            createTestHealthIndicator(
              id: 'cash_discipline',
              title: 'Discipline de trésorerie',
              status: HealthStatus.conforme,
              diagnostic: 'Encaisse cohérente sans écart.',
              recommendation: 'Gardez un fond de caisse propre.',
            ),
            createTestHealthIndicator(
              id: 'location_stability',
              title: 'Stabilité d\'ancrage',
              status: HealthStatus.urgent,
              diagnostic: 'Clôtures réalisées hors boutique.',
              recommendation: 'Clôturez au comptoir avant le départ.',
            ),
          ],
        );

        when(
          () => mockCubit.state,
        ).thenReturn(AdvisorLoaded(financialHealth: health));

        await tester.pumpWidget(buildSubject());

        // Header et titre
        expect(find.text('Conseiller Tekki'), findsOneWidget);

        // Bilan global
        expect(
          find.byKey(const ValueKey('advisor_overall_card')),
          findsOneWidget,
        );
        expect(find.text('Bilan Global'), findsOneWidget);
        expect(
          find.text('Bravo ! Votre boutique se porte très bien.'),
          findsOneWidget,
        );

        // Capsule Audio Conseiller
        expect(find.byType(AudioCapsuleCard), findsOneWidget);
        expect(
          find.byKey(const ValueKey('audio_capsule_card')),
          findsOneWidget,
        );

        // Section 4 repères
        expect(find.text('4 Repères de gestion'), findsOneWidget);

        // 4 Cartes de métriques
        expect(find.byType(HealthTrafficLightCard), findsNWidgets(4));
        expect(find.text('Régularité de caisse'), findsOneWidget);
        expect(find.text('Recouvrement Karné Bor'), findsOneWidget);
        expect(find.text('Discipline de trésorerie'), findsOneWidget);
        expect(find.text('Stabilité d\'ancrage'), findsOneWidget);

        // Diagnostics & Recommandations
        expect(find.text('Clôtures quotidiennes exemplaires.'), findsOneWidget);
        expect(
          find.text('Envoyez un rappel amical sur WhatsApp.'),
          findsOneWidget,
        );

        // Accessibilité : présence des symboles doublés des feux tricolores (✓, ⏳, !)
        expect(find.text('✓ Conforme'), findsWidgets);
        expect(find.text('⏳ Attention'), findsWidgets);
        expect(find.text('! Urgent'), findsWidgets);
      },
    );

    testWidgets('AdvisorHealthBadge displays symbol and label correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdvisorHealthBadge(status: HealthStatus.conforme),
                AdvisorHealthBadge(status: HealthStatus.attention),
                AdvisorHealthBadge(status: HealthStatus.urgent),
              ],
            ),
          ),
        ),
      );

      expect(find.text('✓ Conforme'), findsOneWidget);
      expect(find.text('⏳ Attention'), findsOneWidget);
      expect(find.text('! Urgent'), findsOneWidget);
    });
  });
}
