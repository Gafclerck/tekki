import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/services/demo_data_seeder.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/core/widgets/demo_data_dialog.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_cubit.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_state.dart';
import 'package:tekki/features/financing/presentation/pages/financing_page.dart';
import 'package:tekki/features/navigation/presentation/screens/tekki_navigation_shell.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';
import 'package:tekki/injection_container.dart';

class MockCashDashboardBloc
    extends MockBloc<CashDashboardEvent, CashDashboardState>
    implements CashDashboardBloc {}

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

class MockDemoDataSeederService extends Mock implements DemoDataSeederService {}

void main() {
  late MockCashDashboardBloc mockCashBloc;
  late MockFinancingCubit mockFinancingCubit;
  late MockDemoDataSeederService mockSeeder;

  setUp(() {
    mockCashBloc = MockCashDashboardBloc();
    mockFinancingCubit = MockFinancingCubit();
    mockSeeder = MockDemoDataSeederService();

    when(
      () => mockCashBloc.state,
    ).thenReturn(const CashDashboardLoaded(summary: CashSummaryEntity.empty()));

    when(() => mockFinancingCubit.state).thenReturn(
      const FinancingState(
        status: FinancingStatus.loaded,
        partners: FinancialPartnerCatalog.defaultPartners,
        eligibility: LoanEligibilityEntity(
          isEligible: true,
          maxBorrowingCapacity: 1500000,
          currentScore: 82,
          closuresCount: 14,
          grade: 'A+',
          statusSummary: 'Éligible',
          eligiblePartnerIds: ['baobab_sn', 'cofina_sn'],
        ),
      ),
    );

    sl.registerLazySingleton<DemoDataSeederService>(() => mockSeeder);

    addTearDown(() async {
      await sl.reset();
    });
  });

  Widget buildSubject({int initialIndex = 0}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: TekkiNavigationShell(
        initialIndex: initialIndex,
        cashDashboardBloc: mockCashBloc,
        financingCubit: mockFinancingCubit,
      ),
    );
  }

  group('TekkiNavigationShell Widget Tests', () {
    testWidgets(
      'renders mobile shell with 5 bottom destinations and Financement active by default',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildSubject(initialIndex: 0));

        // Shell AppBar
        expect(
          find.byKey(const ValueKey('tekki_shell_app_bar')),
          findsOneWidget,
        );
        expect(find.text(AppConstants.appName), findsWidgets);
        expect(find.text('Facilitation au Crédit & Prêts'), findsOneWidget);

        // Demo Data Button
        expect(
          find.byKey(const ValueKey('demo_data_action_button')),
          findsOneWidget,
        );

        // Bottom Navigation Bar
        expect(
          find.byKey(const ValueKey('tekki_bottom_navigation_bar')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('nav_financement')), findsOneWidget);
        expect(find.byKey(const ValueKey('nav_passeport')), findsOneWidget);
        expect(find.byKey(const ValueKey('nav_caisse')), findsOneWidget);
        expect(find.byKey(const ValueKey('nav_karne_bor')), findsOneWidget);
        expect(find.byKey(const ValueKey('nav_conseiller')), findsOneWidget);

        // Default active tab is FinancingPage
        expect(find.byType(FinancingPage), findsOneWidget);
      },
    );

    testWidgets('tapping nav destination switches active tab to Caisse', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(initialIndex: 0));

      await tester.tap(find.byKey(const ValueKey('nav_caisse')));
      await tester.pumpAndSettle();

      expect(find.text('Caisse & Point de Vente'), findsOneWidget);
    });

    testWidgets('tapping demo data button opens DemoDataDialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(initialIndex: 0));

      await tester.tap(find.byKey(const ValueKey('demo_data_action_button')));
      await tester.pumpAndSettle();

      expect(find.byType(DemoDataDialog), findsOneWidget);
      expect(
        find.byKey(const ValueKey('seed_full_data_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('clear_all_data_button')),
        findsOneWidget,
      );
    });

    testWidgets('renders wide shell with NavigationRail on width >= 640', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(initialIndex: 0));

      expect(
        find.byKey(const ValueKey('tekki_shell_scaffold_wide')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('tekki_navigation_rail')),
        findsOneWidget,
      );
    });
  });
}
