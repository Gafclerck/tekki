import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/widgets/collect_debt_payment_dialog.dart';

class MockRecordDebtPaymentUseCase extends Mock
    implements RecordDebtPaymentUseCase {}

void main() {
  late MockRecordDebtPaymentUseCase mockUseCase;

  final tDebtor = DebtorEntity(
    id: 'debtor-1',
    name: 'Aminata Ba',
    createdAt: DateTime.utc(2026, 11, 1),
  );

  final tDebt = DebtEntity(
    id: 'debt-5',
    debtorId: 'debtor-1',
    initialAmount: 6000,
    remainingAmount: 6000,
    dueDate: DateTime.utc(2026, 12, 1),
    status: DebtStatus.active,
    createdAt: DateTime.utc(2026, 11, 1),
    debtor: tDebtor,
  );

  final tPayment = DebtPaymentEntity(
    id: 'pay-1',
    debtId: 'debt-5',
    paymentAmount: 6000,
    paymentMethod: 'ESPECES',
    paidAt: DateTime.utc(2026, 11, 17),
  );

  setUpAll(() {
    registerFallbackValue(tDebt);
  });

  setUp(() {
    mockUseCase = MockRecordDebtPaymentUseCase();
  });

  Widget buildTestableWidget({required CollectDebtPaymentCubit cubit}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CollectDebtPaymentDialog.show(
                  context: context,
                  debt: tDebt,
                  cubit: cubit,
                );
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );
  }

  group('CollectDebtPaymentDialog Widget UI', () {
    testWidgets('renders all initial UI elements correctly', (tester) async {
      final cubit = CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      );

      await tester.pumpWidget(buildTestableWidget(cubit: cubit));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('collect_debt_payment_dialog')), findsOneWidget);
      expect(find.text('Encaisser un paiement'), findsOneWidget);
      expect(find.text('Aminata Ba'), findsOneWidget);
      expect(find.text('6 000 FCFA'), findsAtLeastNWidgets(1));
      expect(find.byKey(const ValueKey('collect_full_payment_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('custom_amount_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('collect_custom_payment_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('close_collect_dialog_button')), findsOneWidget);
    });

    testWidgets('tapping 1-click full payment button submits full settlement', (tester) async {
      when(
        () => mockUseCase(
          debt: tDebt,
          paymentAmount: 6000,
          paymentMethod: 'ESPECES',
        ),
      ).thenAnswer((_) async => Success(tPayment));

      final cubit = CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      );

      await tester.pumpWidget(buildTestableWidget(cubit: cubit));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('collect_full_payment_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockUseCase(
          debt: tDebt,
          paymentAmount: 6000,
          paymentMethod: 'ESPECES',
        ),
      ).called(1);

      // Dialog should be popped and SnackBar shown
      expect(find.byKey(const ValueKey('collect_debt_payment_dialog')), findsNothing);
      expect(find.byKey(const ValueKey('collect_payment_success_snackbar')), findsOneWidget);
    });

    testWidgets('entering partial payment amount and submitting', (tester) async {
      final partialPayment = DebtPaymentEntity(
        id: 'pay-part',
        debtId: 'debt-5',
        paymentAmount: 2500,
        paymentMethod: 'ESPECES',
        paidAt: DateTime.utc(2026, 11, 17),
      );

      when(
        () => mockUseCase(
          debt: tDebt,
          paymentAmount: 2500,
          paymentMethod: 'ESPECES',
        ),
      ).thenAnswer((_) async => Success(partialPayment));

      final cubit = CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      );

      await tester.pumpWidget(buildTestableWidget(cubit: cubit));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('custom_amount_field')),
        '2500',
      );
      await tester.pumpAndSettle();

      expect(find.text('Nouveau solde restant : 3 500 FCFA'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('collect_custom_payment_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockUseCase(
          debt: tDebt,
          paymentAmount: 2500,
          paymentMethod: 'ESPECES',
        ),
      ).called(1);
    });

    testWidgets('entering amount exceeding balance shows validation error and disables submit', (tester) async {
      final cubit = CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      );

      await tester.pumpWidget(buildTestableWidget(cubit: cubit));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('custom_amount_field')),
        '10000',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Le montant ne peut pas dépasser le solde restant (6 000 FCFA).'),
        findsOneWidget,
      );

      // Verify custom button is disabled
      final button = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('collect_custom_payment_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping close button dismisses dialog without submission', (tester) async {
      final cubit = CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      );

      await tester.pumpWidget(buildTestableWidget(cubit: cubit));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('close_collect_dialog_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('collect_debt_payment_dialog')), findsNothing);
      verifyZeroInteractions(mockUseCase);
    });
  });
}
