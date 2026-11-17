import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_colors.dart';
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

class MockCashDashboardBloc
    extends MockBloc<CashDashboardEvent, CashDashboardState>
    implements CashDashboardBloc {}

void main() {
  late MockCashDashboardBloc mockBloc;

  setUp(() {
    mockBloc = MockCashDashboardBloc();
  });

  Widget buildSubject({VoidCallback? onCloseCashier}) {
    return MaterialApp(
      home: BlocProvider<CashDashboardBloc>.value(
        value: mockBloc,
        child: HomeScreen(
          onCloseCashier: onCloseCashier,
        ),
      ),
    );
  }

  group('HomeScreen Widget Integration', () {
    testWidgets('renders all primary elements: header, cards, and bottom CTA',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(
          summary: CashSummaryEntity.empty(),
        ),
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

      // Reserved Cards
      expect(find.byKey(const ValueKey('karne_bor_card')), findsOneWidget);
      expect(find.text('Karné Bor'), findsOneWidget);
      expect(find.byKey(const ValueKey('conseiller_card')), findsOneWidget);
      expect(find.text('Conseiller Tekki'), findsOneWidget);

      // Unique Bottom Primary CTA Button
      expect(find.byType(PrimaryCtaButton), findsOneWidget);
      expect(find.text('🔒 Clôturer la caisse'), findsOneWidget);
    });

    testWidgets('has exactly ONE orange accent CTA button on the entire screen',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CashDashboardLoaded(
          summary: CashSummaryEntity.empty(),
        ),
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
    });

    testWidgets('dispatches WatchCashDashboardStarted on mount when in Initial state',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const CashDashboardInitial());

      await tester.pumpWidget(buildSubject());

      verify(() => mockBloc.add(const WatchCashDashboardStarted())).called(1);
    });

    testWidgets('updates CashCard when loaded with active sales',
        (tester) async {
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

    testWidgets('tapping PrimaryCtaButton dispatches CloseCashierTapped and triggers listener',
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
      expect(find.byKey(const ValueKey('closure_initiated_snackbar')), findsOneWidget);
    });

    testWidgets('displays discreet non-blocking error banner on CashDashboardError',
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
    });

    testWidgets('PrimaryCtaButton is disabled when state is not CashDashboardLoaded',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const CashDashboardLoading());

      await tester.pumpWidget(buildSubject());

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
      expect(buttonFinder, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
      expect(elevatedButton.onPressed, isNull);
    });

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
    });

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
  });
}
