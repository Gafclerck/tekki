import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/app.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/features/navigation/presentation/screens/tekki_navigation_shell.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/home_screen.dart';
import 'package:tekki/injection_container.dart' as di;

class MockCashDashboardBloc
    extends MockBloc<CashDashboardEvent, CashDashboardState>
    implements CashDashboardBloc {}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('TekkiApp renders home screen with app name with mocked bloc', (
    tester,
  ) async {
    final mockBloc = MockCashDashboardBloc();
    when(
      () => mockBloc.state,
    ).thenReturn(const CashDashboardLoaded(summary: CashSummaryEntity.empty()));

    await tester.pumpWidget(TekkiApp(cashDashboardBloc: mockBloc));

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text('Point de vente au comptoir'), findsOneWidget);
  });

  testWidgets(
    'TekkiApp renders navigation shell and can navigate to Caisse with initDependencyInjection inMemoryDatabase',
    (tester) async {
      await di.sl.reset();
      await di.initDependencyInjection(inMemoryDatabase: true);

      await tester.pumpWidget(const TekkiApp());
      await tester.pumpAndSettle();

      expect(find.byType(TekkiNavigationShell), findsOneWidget);
      expect(find.text(AppConstants.appName), findsWidgets);
      // Hero Tab 0: Financement is active by default
      expect(find.text('Facilitation au Crédit & Prêts'), findsOneWidget);
      expect(find.text('Capacité d\'emprunt certifiée Tekki'), findsOneWidget);

      // Navigate to Caisse tab (Tab 2)
      await tester.tap(find.text('Caisse').first);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Point de vente au comptoir'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
      await di.sl.reset();
    },
  );
}
