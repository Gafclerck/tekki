import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/services/brightness_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/domain/entities/capsule_playback_state.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_state.dart';
import 'package:tekki/features/advisor/presentation/pages/advisor_page.dart';
import 'package:tekki/features/advisor/presentation/widgets/audio_capsule_card.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import 'package:tekki/features/financial_passport/presentation/pages/passport_overview_page.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';
import 'package:tekki/features/karne_bor/presentation/screens/karne_bor_screen.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/express_closure_screen.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/home_screen.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/cash_card.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/primary_cta_button.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_button.dart';
import 'package:tekki/injection_container.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockCashDashboardBloc
    extends MockBloc<CashDashboardEvent, CashDashboardState>
    implements CashDashboardBloc {}

class MockKarneBorCubit extends Mock implements KarneBorCubit {}

void main() {
  late MockCashDashboardBloc mockBloc;
  late MockAudioCapsuleCubit mockAudioCapsuleCubit;

  setUp(() {
    mockBloc = MockCashDashboardBloc();
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

  Widget buildSubject({VoidCallback? onCloseCashier}) {
    return MaterialApp(
      home: BlocProvider<CashDashboardBloc>.value(
        value: mockBloc,
        child: HomeScreen(onCloseCashier: onCloseCashier),
      ),
    );
  }

  group('HomeScreen Widget Integration', () {
    testWidgets('renders all primary elements: header, cards, and bottom CTA', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
      );

      await tester.pumpWidget(buildSubject());

      // Merchant Header
      expect(find.byKey(const ValueKey('merchant_header')), findsOneWidget);
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text('Point de vente au comptoir'), findsOneWidget);
      expect(find.text('100% Hors-ligne'), findsOneWidget);

      // CashCard & QuickSaleButton
      expect(find.byType(CashCard), findsOneWidget);
      expect(find.byType(QuickSaleButton), findsOneWidget);
      expect(find.text('0 FCFA'), findsOneWidget);

      // AudioCapsuleCard
      expect(find.byType(AudioCapsuleCard), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_capsule_card')), findsOneWidget);

      // Reserved Cards
      expect(find.byKey(const ValueKey('karne_bor_card')), findsOneWidget);
      expect(find.text('Karné Bor'), findsOneWidget);
      expect(find.byKey(const ValueKey('conseiller_card')), findsOneWidget);
      expect(find.text('Conseiller Tekki'), findsOneWidget);

      // Unique Bottom Primary CTA Button
      expect(find.byType(PrimaryCtaButton), findsOneWidget);
      expect(find.text('🔒 Clôturer la caisse'), findsOneWidget);
    });

    testWidgets(
      'has exactly ONE orange accent CTA button on the entire screen',
      (tester) async {
        when(() => mockBloc.state).thenReturn(
          const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
        );

        await tester.pumpWidget(buildSubject());

        // Find all ElevatedButtons
        final elevatedButtons = tester.widgetList<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        // Filter those with background color == AppColors.accent
        final orangeAccentButtons = elevatedButtons.where((button) {
          final bg = button.style?.backgroundColor?.resolve({});
          return bg == AppColors.accent;
        }).toList();

        expect(orangeAccentButtons.length, equals(1));
      },
    );

    testWidgets(
      'dispatches WatchCashDashboardStarted on mount when in Initial state',
      (tester) async {
        when(() => mockBloc.state).thenReturn(const CashDashboardInitial());

        await tester.pumpWidget(buildSubject());

        verify(() => mockBloc.add(const WatchCashDashboardStarted())).called(1);
      },
    );

    testWidgets('updates CashCard when loaded with active sales', (
      tester,
    ) async {
      final sale1 = SaleEntity(
        id: 's1',
        amount: 5000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 8, 0),
      );
      final sale2 = SaleEntity(
        id: 's2',
        amount: 12500,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 9, 0),
      );

      when(() => mockBloc.state).thenReturn(
        CashDashboardLoaded(
          summary: CashSummaryEntity(
            totalAmount: 17500,
            salesCount: 2,
            sales: [sale1, sale2],
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('17 500 FCFA'), findsOneWidget);
      expect(find.text('2 ventes'), findsOneWidget);
    });

    testWidgets(
      'tapping PrimaryCtaButton dispatches CloseCashierTapped and triggers listener',
      (tester) async {
        whenListen(
          mockBloc,
          Stream.fromIterable([
            const CashDashboardLoaded(
              summary: CashSummaryEntity.empty(),
              isClosureLocked: false,
            ),
            const CashDashboardLoaded(
              summary: CashSummaryEntity.empty(),
              isClosureLocked: true,
            ),
          ]),
          initialState: const CashDashboardLoaded(
            summary: CashSummaryEntity.empty(),
            isClosureLocked: false,
          ),
        );

        var callbackTriggered = false;
        await tester.pumpWidget(
          buildSubject(onCloseCashier: () => callbackTriggered = true),
        );

        final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(const CloseCashierTapped())).called(1);
        expect(callbackTriggered, isTrue);
        expect(
          find.byKey(const ValueKey('closure_initiated_snackbar')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays discreet non-blocking error banner on CashDashboardError',
      (tester) async {
        when(() => mockBloc.state).thenReturn(
          const CashDashboardError(message: 'Database query failed'),
        );

        await tester.pumpWidget(buildSubject());

        // Discreet banner exists
        expect(
          find.byKey(const ValueKey('cash_dashboard_error_banner')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Information de caisse temporairement indisponible. Vous pouvez continuer à enregistrer vos ventes.',
          ),
          findsOneWidget,
        );

        // QuickSaleButton is STILL accessible
        expect(find.byType(QuickSaleButton), findsOneWidget);
      },
    );

    testWidgets(
      'PrimaryCtaButton is disabled when state is not CashDashboardLoaded',
      (tester) async {
        when(() => mockBloc.state).thenReturn(const CashDashboardLoading());

        await tester.pumpWidget(buildSubject());

        final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
        expect(buttonFinder, findsOneWidget);

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).last,
        );
        expect(elevatedButton.onPressed, isNull);
      },
    );

    testWidgets(
      'navigates to ExpressClosureScreen when onCloseCashier is null and dispatches ResetClosureLock on cancel',
      (tester) async {
        whenListen(
          mockBloc,
          Stream.fromIterable([
            const CashDashboardLoaded(
              summary: CashSummaryEntity.empty(),
              isClosureLocked: false,
            ),
            const CashDashboardLoaded(
              summary: CashSummaryEntity.empty(),
              isClosureLocked: true,
            ),
          ]),
          initialState: const CashDashboardLoaded(
            summary: CashSummaryEntity.empty(),
            isClosureLocked: false,
          ),
        );

        await tester.pumpWidget(buildSubject(onCloseCashier: null));
        await tester.pumpAndSettle();

        expect(find.byType(ExpressClosureScreen), findsOneWidget);

        // Pop back without completing closure
        final backButton = find.byKey(const ValueKey('back_button'));
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(const ResetClosureLock())).called(1);
      },
    );

    testWidgets('onSaleRecorded triggers floating SnackBar', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
      );

      await tester.pumpWidget(buildSubject());

      final cashCard = tester.widget<CashCard>(find.byType(CashCard));
      expect(cashCard.onSaleRecorded, isNotNull);

      final testSale = SaleEntity(
        id: 'sale-test',
        amount: 2500,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 10, 0),
      );

      cashCard.onSaleRecorded!(testSale);
      await tester.pumpAndSettle();

      expect(find.text('Vente de 2500 FCFA enregistrée !'), findsOneWidget);
    });

    testWidgets('tapping karne_bor_card navigates to KarneBorScreen', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
      );

      final mockKarneCubit = MockKarneBorCubit();
      when(
        () => mockKarneCubit.state,
      ).thenReturn(const KarneBorLoaded(debts: [], totalDebt: 0));
      when(() => mockKarneCubit.startWatching()).thenReturn(null);
      when(() => mockKarneCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockKarneCubit.close()).thenAnswer((_) async {});
      if (sl.isRegistered<KarneBorCubit>()) {
        sl.unregister<KarneBorCubit>();
      }
      sl.registerFactory<KarneBorCubit>(() => mockKarneCubit);

      await tester.pumpWidget(buildSubject());

      final karneBorCard = find.byKey(const ValueKey('karne_bor_card'));
      expect(karneBorCard, findsOneWidget);

      await tester.ensureVisible(karneBorCard);
      await tester.pump();

      await tester.tap(karneBorCard);
      await tester.pumpAndSettle();

      expect(find.byType(KarneBorScreen), findsOneWidget);
    });

    testWidgets('tapping passport_card navigates to PassportOverviewPage', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
      );

      final mockPassportBloc = MockPassportBloc();
      final mockBrightness = MockBrightnessService();
      when(() => mockBrightness.setMaxBrightness()).thenAnswer((_) async {});
      when(() => mockBrightness.restoreBrightness()).thenAnswer((_) async {});
      when(() => mockPassportBloc.state).thenReturn(const PassportLoading());
      when(
        () => mockPassportBloc.stream,
      ).thenAnswer((_) => Stream.value(const PassportLoading()));
      when(() => mockPassportBloc.close()).thenAnswer((_) async {});

      if (sl.isRegistered<PassportBloc>()) {
        sl.unregister<PassportBloc>();
      }
      sl.registerFactory<PassportBloc>(() => mockPassportBloc);
      if (sl.isRegistered<IBrightnessService>()) {
        sl.unregister<IBrightnessService>();
      }
      sl.registerLazySingleton<IBrightnessService>(() => mockBrightness);

      await tester.pumpWidget(buildSubject());

      final passportCard = find.byKey(const ValueKey('passport_card'));
      expect(passportCard, findsOneWidget);

      await tester.ensureVisible(passportCard);
      await tester.pump();

      await tester.tap(passportCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PassportOverviewPage), findsOneWidget);
    });

    testWidgets('tapping conseiller_card navigates to AdvisorPage', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(summary: CashSummaryEntity.empty()),
      );

      final mockAdvisorCubit = MockAdvisorCubit();
      when(() => mockAdvisorCubit.state).thenReturn(const AdvisorLoading());
      when(
        () => mockAdvisorCubit.stream,
      ).thenAnswer((_) => Stream.value(const AdvisorLoading()));
      when(() => mockAdvisorCubit.close()).thenAnswer((_) async {});
      when(
        () => mockAdvisorCubit.loadFinancialHealth(),
      ).thenAnswer((_) async {});

      if (sl.isRegistered<AdvisorCubit>()) {
        sl.unregister<AdvisorCubit>();
      }
      sl.registerFactory<AdvisorCubit>(() => mockAdvisorCubit);

      await tester.pumpWidget(buildSubject());

      final conseillerCard = find.byKey(const ValueKey('conseiller_card'));
      expect(conseillerCard, findsOneWidget);
      expect(find.byKey(const ValueKey('home_advisor_badge')), findsOneWidget);

      await tester.ensureVisible(conseillerCard);
      await tester.pump();

      await tester.tap(conseillerCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AdvisorPage), findsOneWidget);
    });
  });
}
