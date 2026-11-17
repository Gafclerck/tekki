import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import 'package:tekki/features/financial_passport/presentation/pages/passport_overview_page.dart';
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
  final testSignedPayload = createTestSignedPassportPayload(
    passport: eligiblePassport,
    visualPin: '4821',
  );

  final activeState = PassportActiveLoaded(
    passport: eligiblePassport,
    signedPayload: testSignedPayload,
    secondsRemainingInMinute: 45,
    lastUpdated: testDate,
  );

  setUpAll(() {
    registerFallbackValue(const SharePassportPdfEvent());
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
  });

  tearDown(() async {
    await sl.reset();
  });

  group('PassportOverviewPage Share PDF Integration Tests', () {
    testWidgets(
      'renders share button and tapping it dispatches SharePassportPdfEvent',
      (tester) async {
        when(() => mockPassportBloc.state).thenReturn(activeState);
        when(
          () => mockPassportBloc.stream,
        ).thenAnswer((_) => Stream.value(activeState));

        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
            shopId: 'boutique-test',
          ),
        );

        final buttonFinder = find.byKey(
          const ValueKey('share_pdf_whatsapp_button'),
        );
        expect(buttonFinder, findsOneWidget);
        await tester.ensureVisible(buttonFinder);
        await tester.pumpAndSettle();

        expect(
          find.text('📲 Partager l\'Attestation PDF sur WhatsApp'),
          findsOneWidget,
        );

        await tester.tap(buttonFinder);
        await tester.pump();

        verify(
          () => mockPassportBloc.add(any(that: isA<SharePassportPdfEvent>())),
        ).called(1);
      },
    );

    testWidgets(
      'shows loading spinner and disables button when isSharingPdf is true',
      (tester) async {
        final sharingState = activeState.copyWith(isSharingPdf: true);
        when(() => mockPassportBloc.state).thenReturn(sharingState);
        when(
          () => mockPassportBloc.stream,
        ).thenAnswer((_) => Stream.value(sharingState));

        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
          ),
        );

        expect(
          find.byKey(const ValueKey('share_pdf_loading_spinner')),
          findsOneWidget,
        );
        expect(find.text('Génération de l\'attestation...'), findsOneWidget);

        final buttonWidget = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('share_pdf_whatsapp_button')),
        );
        expect(buttonWidget.onPressed, isNull);
      },
    );

    testWidgets('displays error SnackBar when sharePdfError is present', (
      tester,
    ) async {
      final errorState = activeState.copyWith(
        sharePdfError: 'Erreur d\'exportation PDF',
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

      await tester.pump();

      expect(find.text('Erreur d\'exportation PDF'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('passport_share_error_snackbar')),
        findsOneWidget,
      );
    });

    testWidgets(
      'displays success SnackBar when pdfSharedSuccessfully is true',
      (tester) async {
        final successState = activeState.copyWith(pdfSharedSuccessfully: true);
        when(() => mockPassportBloc.state).thenReturn(successState);
        when(
          () => mockPassportBloc.stream,
        ).thenAnswer((_) => Stream.value(successState));

        await tester.pumpTekkiWidget(
          PassportOverviewPage(
            brightnessService: mockBrightnessService,
            bloc: mockPassportBloc,
            enablePeriodicTicker: false,
          ),
        );

        await tester.pump();

        expect(
          find.text('Attestation PDF générée et partagée avec succès !'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('passport_share_success_snackbar')),
          findsOneWidget,
        );
      },
    );
  });
}
