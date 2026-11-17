import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/screens/karne_bor_screen.dart';

class MockWatchActiveDebtsUseCase extends Mock
    implements WatchActiveDebtsUseCase {}

class MockRecordDebtUseCase extends Mock implements RecordDebtUseCase {}

class MockGetDebtorsUseCase extends Mock implements GetDebtorsUseCase {}

class FakeRecordDebtParams extends Fake implements RecordDebtParams {}

void main() {
  late MockWatchActiveDebtsUseCase mockWatchActiveDebtsUseCase;
  late MockRecordDebtUseCase mockRecordDebtUseCase;
  late MockGetDebtorsUseCase mockGetDebtorsUseCase;

  final testDate = DateTime.utc(2026, 11, 17);

  setUpAll(() {
    registerFallbackValue(FakeRecordDebtParams());
  });

  setUp(() {
    mockWatchActiveDebtsUseCase = MockWatchActiveDebtsUseCase();
    mockRecordDebtUseCase = MockRecordDebtUseCase();
    mockGetDebtorsUseCase = MockGetDebtorsUseCase();
  });

  Widget createWidgetUnderTest({
    List<DebtEntity> initialDebts = const [],
    List<DebtorEntity> knownDebtors = const [],
  }) {
    when(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')))
        .thenAnswer((_) => Stream.value(initialDebts));
    when(
      () => mockGetDebtorsUseCase.call(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Success(knownDebtors));

    final karneCubit = KarneBorCubit(
      watchActiveDebtsUseCase: mockWatchActiveDebtsUseCase,
    );
    final debtCubit = RecordDebtCubit(
      recordDebtUseCase: mockRecordDebtUseCase,
      getDebtorsUseCase: mockGetDebtorsUseCase,
    );

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: KarneBorScreen(
        karneBorCubit: karneCubit,
        recordDebtCubit: debtCubit,
      ),
    );
  }

  group('KarneBorScreen Widget Tests', () {
    testWidgets('renders header, summary card and empty state when no debts', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(initialDebts: []));
      await tester.pumpAndSettle();

      expect(find.text('Karné Bor'), findsOneWidget);
      expect(find.text('Carnet Numérique'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('karne_bor_summary_card')),
        findsOneWidget,
      );
      expect(find.text('0 FCFA'), findsOneWidget);
      expect(find.text('0 créance'), findsOneWidget);

      expect(
        find.text('Aucun argent dehors ! Vos créances sont toutes à jour.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('add_debt_button')), findsOneWidget);
    });

    testWidgets(
      'renders list of active debts with name, amount and overdue badge',
      (tester) async {
        final debtor1 = DebtorEntity(
          id: 'd-1',
          name: 'Modou Fall',
          createdAt: testDate,
        );
        final debtor2 = DebtorEntity(
          id: 'd-2',
          name: 'Fatou Kiné',
          createdAt: testDate,
        );

        final debts = [
          DebtEntity(
            id: 'debt-overdue',
            debtorId: 'd-1',
            initialAmount: 15000,
            remainingAmount: 15000,
            dueDate: DateTime.now().toUtc().subtract(
              const Duration(days: 3),
            ), // Overdue!
            status: DebtStatus.active,
            createdAt: testDate,
            debtor: debtor1,
          ),
          DebtEntity(
            id: 'debt-nominal',
            debtorId: 'd-2',
            initialAmount: 5000,
            remainingAmount: 5000,
            dueDate: DateTime.now().toUtc().add(
              const Duration(days: 4),
            ), // Future!
            status: DebtStatus.active,
            createdAt: testDate,
            debtor: debtor2,
          ),
        ];

        await tester.pumpWidget(createWidgetUnderTest(initialDebts: debts));
        await tester.pumpAndSettle();

        expect(find.text('Modou Fall'), findsOneWidget);
        expect(find.text('15 000 FCFA'), findsOneWidget);
        expect(find.text('⚠️ Retard'), findsOneWidget);

        expect(find.text('Fatou Kiné'), findsOneWidget);
        expect(find.text('5 000 FCFA'), findsOneWidget);
        expect(find.text('À jour'), findsOneWidget);

        expect(find.text('20 000 FCFA'), findsOneWidget); // 15000 + 5000
        expect(find.text('2 créances'), findsOneWidget);
      },
    );

    testWidgets('tapping add debt button opens bottom sheet and records debt', (
      tester,
    ) async {
      final recordedDebt = DebtEntity(
        id: 'new-debt-id',
        debtorId: 'new-debtor-id',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: testDate.add(const Duration(days: 7)),
        createdAt: testDate,
        debtor: DebtorEntity(
          id: 'new-debtor-id',
          name: 'Fatou Kiné',
          createdAt: testDate,
        ),
      );

      when(() => mockRecordDebtUseCase.call(any()))
          .thenAnswer((_) async => Success(recordedDebt));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap CTA button
      await tester.tap(find.byKey(const ValueKey('add_debt_button')));
      await tester.pumpAndSettle();

      // Bottom sheet is visible
      expect(
        find.byKey(const ValueKey('record_debt_bottom_sheet')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('debtor_name_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('debt_amount_input')), findsOneWidget);

      // Enter name and amount
      await tester.enterText(
        find.byKey(const ValueKey('debtor_name_input')),
        'Fatou Kiné',
      );
      await tester.enterText(
        find.byKey(const ValueKey('debt_amount_input')),
        '5000',
      );
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.byKey(const ValueKey('submit_debt_button')));
      await tester.pumpAndSettle();

      // Modal is closed and confirmation SnackBar is displayed
      expect(
        find.byKey(const ValueKey('record_debt_bottom_sheet')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('debt_recorded_snackbar')),
        findsOneWidget,
      );
      expect(find.textContaining('Fatou Kiné'), findsOneWidget);
    });

    testWidgets('tapping back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => createWidgetUnderTest(),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.byType(KarneBorScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('karne_bor_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(KarneBorScreen), findsNothing);
    });
  });
}
