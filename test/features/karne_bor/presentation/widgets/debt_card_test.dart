import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/presentation/widgets/debt_card.dart';

void main() {
  final testDate = DateTime.utc(2026, 11, 17, 12, 0);

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  group('DebtCard Widget Tests', () {
    testWidgets('renders nominal active debt (not overdue, no partial payment)', (tester) async {
      final debtor = DebtorEntity(
        id: 'debtor-1',
        name: 'Moussa Diop',
        createdAt: testDate,
      );

      final debt = DebtEntity(
        id: 'debt-nominal-1',
        debtorId: 'debtor-1',
        initialAmount: 15000,
        remainingAmount: 15000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 5)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: debtor,
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debt)));
      await tester.pumpAndSettle();

      expect(find.text('Moussa Diop'), findsOneWidget);
      expect(find.text('15 000 FCFA'), findsOneWidget);
      expect(find.text('À jour'), findsOneWidget);
      expect(find.text('⚠️ Retard'), findsNothing);
      expect(find.textContaining('Solde restant sur'), findsNothing);
      expect(find.text('💬 Relance WhatsApp'), findsOneWidget);
      expect(find.text('✓ Encaisser'), findsOneWidget);

      final container = tester.widget<Container>(find.byKey(ValueKey('debt_card_${debt.id}')));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.tertiary.withValues(alpha: 0.4));
      expect(border.top.width, 1.0);
    });

    testWidgets('renders overdue debt with alert badge and accent border', (tester) async {
      final debtor = DebtorEntity(
        id: 'debtor-2',
        name: 'Awa Fall',
        createdAt: testDate,
      );

      final debt = DebtEntity(
        id: 'debt-overdue-1',
        debtorId: 'debtor-2',
        initialAmount: 25000,
        remainingAmount: 25000,
        dueDate: DateTime.now().toUtc().subtract(const Duration(days: 4)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: debtor,
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debt)));
      await tester.pumpAndSettle();

      expect(find.text('Awa Fall'), findsOneWidget);
      expect(find.text('25 000 FCFA'), findsOneWidget);
      expect(find.text('⚠️ Retard'), findsOneWidget);
      expect(find.text('À jour'), findsNothing);

      final container = tester.widget<Container>(find.byKey(ValueKey('debt_card_${debt.id}')));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.accent);
      expect(border.top.width, 1.5);
    });

    testWidgets('renders partial payment with remaining balance subtitle', (tester) async {
      final debtor = DebtorEntity(
        id: 'debtor-3',
        name: 'Ibrahima Ndiaye',
        createdAt: testDate,
      );

      final debt = DebtEntity(
        id: 'debt-partial-1',
        debtorId: 'debtor-3',
        initialAmount: 10000,
        remainingAmount: 4000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 3)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: debtor,
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debt)));
      await tester.pumpAndSettle();

      expect(find.text('Ibrahima Ndiaye'), findsOneWidget);
      expect(find.text('4 000 FCFA'), findsOneWidget);
      expect(find.text('Solde restant sur 10 000 FCFA'), findsOneWidget);
    });

    testWidgets('fallback to "Client" when debtor is null or empty/whitespace', (tester) async {
      final debtNull = DebtEntity(
        id: 'debt-no-debtor',
        debtorId: 'debtor-none',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 1)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: null,
      );

      final debtWhitespace = DebtEntity(
        id: 'debt-whitespace-debtor',
        debtorId: 'debtor-empty',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 1)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: DebtorEntity(id: 'debtor-empty', name: '   ', createdAt: testDate),
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debtNull)));
      await tester.pumpAndSettle();
      expect(find.text('Client'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debtWhitespace)));
      await tester.pumpAndSettle();
      expect(find.text('Client'), findsOneWidget);
    });

    testWidgets('shows informational SnackBar when callbacks are null and buttons tapped', (tester) async {
      final debt = DebtEntity(
        id: 'debt-no-callbacks',
        debtorId: 'debtor-1',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 1)),
        status: DebtStatus.active,
        createdAt: testDate,
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debt)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('debt_card_reminder_button_${debt.id}')));
      await tester.pumpAndSettle();
      expect(find.textContaining('La relance WhatsApp sera disponible avec la Story 2.4.'), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('debt_card_collect_button_${debt.id}')));
      await tester.pumpAndSettle();
      expect(find.textContaining("L'encaissement de créance sera disponible avec la Story 2.3."), findsOneWidget);
    });

    testWidgets('triggers onCollect and onReminder callbacks when tapped', (tester) async {
      var collectTapped = false;
      var reminderTapped = false;

      final debt = DebtEntity(
        id: 'debt-actions',
        debtorId: 'debtor-4',
        initialAmount: 8000,
        remainingAmount: 8000,
        dueDate: DateTime.now().toUtc().add(const Duration(days: 2)),
        status: DebtStatus.active,
        createdAt: testDate,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          DebtCard(
            debt: debt,
            onCollect: () => collectTapped = true,
            onReminder: () => reminderTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('debt_card_reminder_button_${debt.id}')));
      await tester.pumpAndSettle();
      expect(reminderTapped, isTrue);

      await tester.tap(find.byKey(ValueKey('debt_card_collect_button_${debt.id}')));
      await tester.pumpAndSettle();
      expect(collectTapped, isTrue);
    });

    testWidgets('action touch targets meet min touch target >= 48dp', (tester) async {
      final debt = DebtEntity(
        id: 'debt-touch-target',
        debtorId: 'debtor-5',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: testDate,
        createdAt: testDate,
      );

      await tester.pumpWidget(buildTestableWidget(DebtCard(debt: debt)));
      await tester.pumpAndSettle();

      final reminderFinder = find.byKey(ValueKey('debt_card_reminder_button_${debt.id}'));
      final collectFinder = find.byKey(ValueKey('debt_card_collect_button_${debt.id}'));

      final reminderSize = tester.getSize(reminderFinder);
      final collectSize = tester.getSize(collectFinder);

      expect(reminderSize.height, greaterThanOrEqualTo(48.0));
      expect(reminderSize.width, greaterThanOrEqualTo(48.0));

      expect(collectSize.height, greaterThanOrEqualTo(48.0));
      expect(collectSize.width, greaterThanOrEqualTo(48.0));
    });
  });
}
