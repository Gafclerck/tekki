import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import 'package:tekki/features/financial_passport/presentation/pages/passport_overview_page.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_encouragement_view.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_qr_card.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_score_badge_card.dart';
import 'package:tekki/injection_container.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockBrightnessService mockBrightnessService;
  late MockPassportBloc mockPassportBloc;

  final testDate = DateTime.utc(2026, 11, 17, 12, 0);

  final eligiblePassport = createTestFinancialPassport(
    overallScore: 82,
    streak: 12,
    totalClosures: 22,
    isEligible: true,
    calculatedAt: testDate,
  );

  final ineligiblePassport = createTestFinancialPassport(
    overallScore: 40,
    streak: 3,
    totalClosures: 4,
    remainingClosures: 3,
    isEligible: false,
    calculatedAt: testDate,
  );

  final testSignedPayload = createTestSignedPassportPayload(
    passport: eligiblePassport,
    visualPin: '4821',
    base45Payload: 'TEKKI-BASE45-PAYLOAD',
  );

  setUpAll(() {
    registerFallbackValue(const LoadPassportEvent());
    registerFallbackValue(const RefreshPinTickEvent());
  });

  setUp(() {
    mockBrightnessService = MockBrightnessService();
    mockPassportBloc = MockPassportBloc();

    when(
      () => mockBrightnessService.setMaxBrightness(),
    ).thenAnswer((_) async {});
    when(
      () => mockBrightnessService.restoreBrightness(),
    ).thenAnswer((_) async {});

    when(() => mockPassportBloc.state).thenReturn(const PassportLoading());
    when(
      () => mockPassportBloc.stream,
    ).thenAnswer((_) => Stream.value(const PassportLoading()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('PassportOverviewPage Widget Integration Tests', () {
    testWidgets(
      'calls setMaxBrightness on mount and restoreBrightness on unmount',
      (tester) async {
        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
          ),
        );

        verify(() => mockBrightnessService.setMaxBrightness()).called(1);
        verifyNever(() => mockBrightnessService.restoreBrightness());

        // Replace widget to trigger dispose
        await tester.pumpWidget(const SizedBox.shrink());

        verify(() => mockBrightnessService.restoreBrightness()).called(1);
      },
    );

    testWidgets('renders loading spinner when in PassportLoading state', (
      tester,
    ) async {
      when(() => mockPassportBloc.state).thenReturn(const PassportLoading());
      when(
        () => mockPassportBloc.stream,
      ).thenAnswer((_) => Stream.value(const PassportLoading()));

      await tester.pumpTekkiWidget(
        PassportOverviewPage(
          brightnessService: mockBrightnessService,
          bloc: mockPassportBloc,
          enablePeriodicTicker: false,
        ),
      );

      expect(
        find.byKey(const ValueKey('passport_loading_indicator')),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders encouragement view when in PassportEncouragementLoaded state (< 7 closures)',
      (tester) async {
        when(() => mockPassportBloc.state).thenReturn(
          PassportEncouragementLoaded(
            passport: ineligiblePassport,
            closuresNeeded: 3,
          ),
        );
        when(() => mockPassportBloc.stream).thenAnswer(
          (_) => Stream.value(
            PassportEncouragementLoaded(
              passport: ineligiblePassport,
              closuresNeeded: 3,
            ),
          ),
        );

        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
          ),
        );

        expect(find.byType(PassportEncouragementView), findsOneWidget);
        expect(
          find.byKey(const ValueKey('encouragement_message_text')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Encore 3 clôtures pour générer votre premier Passeport Financier officiel.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('encouragement_progress_bar')),
          findsOneWidget,
        );
        // Ensure no official QR card is shown in encouragement state
        expect(find.byType(PassportQrCard), findsNothing);
      },
    );

    testWidgets(
      'renders active passport view with QR card, score badge and PIN when in PassportActiveLoaded state',
      (tester) async {
        final loadedState = PassportActiveLoaded(
          passport: eligiblePassport,
          signedPayload: testSignedPayload,
          secondsRemainingInMinute: 45,
          lastUpdated: testDate,
        );
        when(() => mockPassportBloc.state).thenReturn(loadedState);
        when(
          () => mockPassportBloc.stream,
        ).thenAnswer((_) => Stream.value(loadedState));

        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
          ),
        );

        expect(find.byType(PassportScoreBadgeCard), findsOneWidget);
        expect(find.byType(PassportQrCard), findsOneWidget);
        expect(find.text('82'), findsOneWidget);
        expect(find.text('4821'), findsOneWidget);
        expect(find.text('45s'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('share_pdf_whatsapp_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders error banner and retry button on PassportError', (
      tester,
    ) async {
      const errorState = PassportError(
        message: 'Impossible de calculer le passeport',
      );
      when(() => mockPassportBloc.state).thenReturn(errorState);
      when(
        () => mockPassportBloc.stream,
      ).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpTekkiWidget(
        PassportOverviewPage(
          brightnessService: mockBrightnessService,
          bloc: mockPassportBloc,
          enablePeriodicTicker: false,
        ),
      );

      expect(
        find.byKey(const ValueKey('passport_error_message')),
        findsOneWidget,
      );
      expect(find.text('Impossible de calculer le passeport'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('passport_retry_button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('passport_retry_button')));
      await tester.pump();

      verify(
        () => mockPassportBloc.add(any(that: isA<LoadPassportEvent>())),
      ).called(1);
    });

    testWidgets(
      'tapping back button pops the page and triggers restoreBrightness',
      (tester) async {
        when(() => mockPassportBloc.state).thenReturn(
          PassportEncouragementLoaded(
            passport: ineligiblePassport,
            closuresNeeded: 3,
          ),
        );
        when(() => mockPassportBloc.stream).thenAnswer(
          (_) => Stream.value(
            PassportEncouragementLoaded(
              passport: ineligiblePassport,
              closuresNeeded: 3,
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PassportOverviewPage(
                          brightnessService: mockBrightnessService,
                          bloc: mockPassportBloc,
                          enablePeriodicTicker: false,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Passport'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Passport'));
        await tester.pumpAndSettle();

        verify(() => mockBrightnessService.setMaxBrightness()).called(1);
        expect(find.byType(PassportOverviewPage), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('passport_back_button')));
        await tester.pumpAndSettle();

        expect(find.byType(PassportOverviewPage), findsNothing);
        verify(() => mockBrightnessService.restoreBrightness()).called(1);
      },
    );

    testWidgets('periodic ticker dispatches RefreshPinTickEvent every second', (
      tester,
    ) async {
      await tester.pumpTekkiWidget(
        PassportOverviewPage(
          brightnessService: mockBrightnessService,
          bloc: mockPassportBloc,
          enablePeriodicTicker: true,
        ),
      );

      // Advance by 1 second
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => mockPassportBloc.add(any(that: isA<RefreshPinTickEvent>())),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
