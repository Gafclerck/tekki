import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/services/whatsapp_service.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/recovery_velocity_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/screens/karne_bor_screen.dart';
import 'package:tekki/features/karne_bor/presentation/widgets/debt_card.dart';
import 'package:tekki/injection_container.dart';

class MockWatchActiveDebtsUseCase extends Mock implements WatchActiveDebtsUseCase {}
class MockRecordDebtUseCase extends Mock implements RecordDebtUseCase {}
class MockGetDebtorsUseCase extends Mock implements GetDebtorsUseCase {}
class MockRecordDebtPaymentUseCase extends Mock implements RecordDebtPaymentUseCase {}
class MockCalculateRecoveryVelocityUseCase extends Mock implements CalculateRecoveryVelocityUseCase {}
class MockWhatsAppService extends Mock implements IWhatsAppService {}
class MockDebtRepository extends Mock implements DebtRepository {}

class FakeRecordDebtParams extends Fake implements RecordDebtParams {}

void main() {
  late MockWatchActiveDebtsUseCase mockWatchActiveDebtsUseCase;
  late MockRecordDebtUseCase mockRecordDebtUseCase;
  late MockGetDebtorsUseCase mockGetDebtorsUseCase;

  final now = DateTime.now().toUtc();
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
    Stream<List<DebtEntity>>? debtsStream,
    List<DebtorEntity> knownDebtors = const [],
    CalculateRecoveryVelocityUseCase? calculateRecoveryVelocityUseCase,
  }) {
    when(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')))
        .thenAnswer((_) => debtsStream ?? Stream.value(initialDebts));
    when(() => mockGetDebtorsUseCase.call(query: any(named: 'query'), limit: any(named: 'limit')))
        .thenAnswer((_) async => Success(knownDebtors));

    final karneCubit = KarneBorCubit(
      watchActiveDebtsUseCase: mockWatchActiveDebtsUseCase,
      calculateRecoveryVelocityUseCase: calculateRecoveryVelocityUseCase,
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
    testWidgets('renders header, summary card and empty state when no debts',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(initialDebts: []));
      await tester.pumpAndSettle();

      expect(find.text('Karné Bor'), findsOneWidget);
      expect(find.text('Carnet Numérique'), findsOneWidget);
      expect(find.byKey(const ValueKey('karne_bor_summary_card')), findsOneWidget);
      expect(find.text('ARGENT DEHORS'), findsOneWidget);
      expect(find.text('0 FCFA'), findsOneWidget);
      expect(find.text('0 créance'), findsOneWidget);
      expect(find.byKey(const ValueKey('karne_bor_overdue_badge')), findsNothing);

      expect(
        find.text('Aucun argent dehors ! Vos créances sont toutes à jour.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('add_debt_button')), findsOneWidget);
    });

    testWidgets('renders list of active debts with name, amount, overdue badge and actions',
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
          dueDate: now.subtract(const Duration(days: 3)), // Overdue!
          status: DebtStatus.active,
          createdAt: testDate,
          debtor: debtor1,
        ),
        DebtEntity(
          id: 'debt-nominal',
          debtorId: 'd-2',
          initialAmount: 5000,
          remainingAmount: 5000,
          dueDate: now.add(const Duration(days: 4)), // Future!
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
      expect(find.byKey(const ValueKey('karne_bor_overdue_badge')), findsOneWidget);
      expect(find.text('1 en retard'), findsOneWidget);

      // Verify DebtCard action buttons are present
      expect(find.text('💬 Relance WhatsApp'), findsNWidgets(2));
      expect(find.text('✓ Encaisser'), findsNWidgets(2));

      // Verify order: overdue in front
      final cards = tester.widgetList<DebtCard>(find.byType(DebtCard)).toList();
      expect(cards.length, 2);
      expect(cards[0].debt.id, 'debt-overdue');
      expect(cards[1].debt.id, 'debt-nominal');
    });

    testWidgets('mixed debts scenario: 2 overdue and 1 upcoming with display typography and badge',
        (tester) async {
      final debtorA = DebtorEntity(id: 'd-a', name: 'Client A', createdAt: testDate);
      final debtorB = DebtorEntity(id: 'd-b', name: 'Client B', createdAt: testDate);
      final debtorC = DebtorEntity(id: 'd-c', name: 'Client C', createdAt: testDate);

      // 2 overdue (10 000 F and 5 000 F) and 1 upcoming (15 000 F)
      final debts = [
        DebtEntity(
          id: 'debt-upcoming',
          debtorId: 'd-c',
          initialAmount: 15000,
          remainingAmount: 15000,
          dueDate: now.add(const Duration(days: 5)),
          status: DebtStatus.active,
          createdAt: testDate,
          debtor: debtorC,
        ),
        DebtEntity(
          id: 'debt-overdue-older',
          debtorId: 'd-a',
          initialAmount: 10000,
          remainingAmount: 10000,
          dueDate: now.subtract(const Duration(days: 7)),
          status: DebtStatus.active,
          createdAt: testDate,
          debtor: debtorA,
        ),
        DebtEntity(
          id: 'debt-overdue-newer',
          debtorId: 'd-b',
          initialAmount: 5000,
          remainingAmount: 5000,
          dueDate: now.subtract(const Duration(days: 2)),
          status: DebtStatus.active,
          createdAt: testDate,
          debtor: debtorB,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(initialDebts: debts));
      await tester.pumpAndSettle();

      // Total is 30 000 FCFA
      expect(find.text('30 000 FCFA'), findsOneWidget);
      expect(find.text('3 créances'), findsOneWidget);
      expect(find.byKey(const ValueKey('karne_bor_overdue_badge')), findsOneWidget);
      expect(find.text('2 en retard'), findsOneWidget);

      // Cards order: overdue-older, overdue-newer, upcoming
      final cards = tester.widgetList<DebtCard>(find.byType(DebtCard)).toList();
      expect(cards.length, 3);
      expect(cards[0].debt.id, 'debt-overdue-older');
      expect(cards[1].debt.id, 'debt-overdue-newer');
      expect(cards[2].debt.id, 'debt-upcoming');
    });

    testWidgets('stream updates reactively when new debt is added', (tester) async {
      final streamController = StreamController<List<DebtEntity>>();

      await tester.pumpWidget(
        createWidgetUnderTest(debtsStream: streamController.stream),
      );
      // Emit initial empty state
      streamController.add([]);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('0 FCFA'), findsOneWidget);
      expect(find.text('0 créance'), findsOneWidget);
      expect(find.byType(DebtCard), findsNothing);

      // New debt emitted reactively
      final newDebt = DebtEntity(
        id: 'reactive-debt-1',
        debtorId: 'd-r1',
        initialAmount: 12000,
        remainingAmount: 12000,
        dueDate: now.add(const Duration(days: 3)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: DebtorEntity(id: 'd-r1', name: 'Ousmane Sarr', createdAt: testDate),
      );
      streamController.add([newDebt]);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('12 000 FCFA'), findsNWidgets(2)); // in summary card and in debt card
      expect(find.text('1 créance'), findsOneWidget);
      expect(find.text('Ousmane Sarr'), findsOneWidget);
      expect(find.byType(DebtCard), findsOneWidget);

      await streamController.close();
    });

    testWidgets('renders error message and retry button on stream failure and retries on tap',
        (tester) async {
      when(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.error('Erreur de connexion SQLite'));

      final karneCubit = KarneBorCubit(
        watchActiveDebtsUseCase: mockWatchActiveDebtsUseCase,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: KarneBorScreen(
            karneBorCubit: karneCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur de connexion SQLite'), findsOneWidget);
      expect(find.byKey(const ValueKey('karne_bor_retry_button')), findsOneWidget);

      // Verify tapping retry button invokes watchActiveDebtsUseCase again
      clearInteractions(mockWatchActiveDebtsUseCase);
      when(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value([]));

      await tester.tap(find.byKey(const ValueKey('karne_bor_retry_button')));
      await tester.pumpAndSettle();

      verify(() => mockWatchActiveDebtsUseCase.call(limit: any(named: 'limit'))).called(1);
      expect(find.text('Tout est en règle !'), findsOneWidget);
    });

    testWidgets('tapping add debt button opens bottom sheet and records debt',
        (tester) async {
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
      expect(find.byKey(const ValueKey('record_debt_bottom_sheet')), findsOneWidget);
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
      expect(find.byKey(const ValueKey('record_debt_bottom_sheet')), findsNothing);
      expect(find.byKey(const ValueKey('debt_recorded_snackbar')), findsOneWidget);
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

    testWidgets('tapping collect button on a debt card opens CollectDebtPaymentDialog', (tester) async {
      final mockRecordPaymentUseCase = MockRecordDebtPaymentUseCase();
      if (sl.isRegistered<RecordDebtPaymentUseCase>()) {
        sl.unregister<RecordDebtPaymentUseCase>();
      }
      sl.registerSingleton<RecordDebtPaymentUseCase>(mockRecordPaymentUseCase);

      final debt = DebtEntity(
        id: 'debt-collect-test',
        debtorId: 'debtor-1',
        initialAmount: 7000,
        remainingAmount: 7000,
        dueDate: now.add(const Duration(days: 3)),
        status: DebtStatus.active,
        createdAt: now,
        debtor: DebtorEntity(
          id: 'debtor-1',
          name: 'Moussa Ndiaye',
          createdAt: now,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialDebts: [debt]));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('debt_card_collect_button_${debt.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('collect_debt_payment_dialog')), findsOneWidget);
      expect(find.text('Encaisser un paiement'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('collect_debt_payment_dialog')),
          matching: find.text('Moussa Ndiaye'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('close_collect_dialog_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('collect_debt_payment_dialog')), findsNothing);
    });

    testWidgets('renders recovery velocity gauge and recovery badge in summary card', (tester) async {
      final mockVelocityUseCase = MockCalculateRecoveryVelocityUseCase();
      const velocity = RecoveryVelocityEntity(
        rate: 85,
        totalDueAmount: 100000,
        totalRecoveredAmount: 85000,
        healthStatus: 'Excellente santé financière : vos créances rentrent vite !',
        healthLevel: RecoveryHealthLevel.excellent,
      );

      when(() => mockVelocityUseCase.call()).thenAnswer((_) async => const Success(velocity));

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialDebts: [],
          calculateRecoveryVelocityUseCase: mockVelocityUseCase,
        ),
      );
      await tester.pumpAndSettle();

      // Summary card contains recovery rate badge
      expect(find.byKey(const ValueKey('karne_bor_recovery_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('karne_bor_recovery_badge')),
          matching: find.text('Recouvrement 85%'),
        ),
        findsOneWidget,
      );

      // Recovery gauge is rendered
      expect(find.byKey(const ValueKey('karne_bor_recovery_gauge')), findsOneWidget);
      expect(find.text('Excellente santé financière : vos créances rentrent vite !'), findsOneWidget);
      expect(find.byKey(const ValueKey('recovery_velocity_progress_bar')), findsOneWidget);
    });

    testWidgets('tapping reminder button on debt card opens WhatsAppReminderBottomSheet', (tester) async {
      final mockWhatsApp = MockWhatsAppService();
      if (sl.isRegistered<IWhatsAppService>()) {
        sl.unregister<IWhatsAppService>();
      }
      sl.registerSingleton<IWhatsAppService>(mockWhatsApp);
      when(() => mockWhatsApp.sanitizePhoneNumber(any())).thenAnswer((inv) => '221771234567');

      final debt = DebtEntity(
        id: 'debt-reminder-test',
        debtorId: 'debtor-rem',
        initialAmount: 12000,
        remainingAmount: 12000,
        dueDate: now.subtract(const Duration(days: 3)), // Overdue
        status: DebtStatus.active,
        createdAt: now,
        debtor: DebtorEntity(
          id: 'debtor-rem',
          name: 'Modou Fall',
          phoneNumber: '771234567',
          createdAt: now,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialDebts: [debt]));
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('debt_card_reminder_button_${debt.id}')), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('debt_card_reminder_button_${debt.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('whatsapp_reminder_bottom_sheet')), findsOneWidget);
      expect(find.text('Relance WhatsApp 1-Clic'), findsOneWidget);
      expect(find.textContaining('Modou Fall'), findsWidgets);
    });
  });
}
