import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/services/whatsapp_service.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet.dart';

class MockWhatsAppService extends Mock implements IWhatsAppService {}

class MockDebtRepository extends Mock implements DebtRepository {}

class FakeDebtorEntity extends Fake implements DebtorEntity {}

void main() {
  late MockWhatsAppService mockWhatsAppService;
  late MockDebtRepository mockDebtRepository;

  final now = DateTime.now().toUtc();
  final testDate = DateTime.utc(2026, 11, 17);

  setUpAll(() {
    registerFallbackValue(FakeDebtorEntity());
  });

  setUp(() {
    mockWhatsAppService = MockWhatsAppService();
    mockDebtRepository = MockDebtRepository();

    when(() => mockDebtRepository.updateDebtor(any())).thenAnswer((inv) async {
      final debtor = inv.positionalArguments[0] as DebtorEntity;
      return Success(debtor);
    });

    when(() => mockWhatsAppService.sanitizePhoneNumber(any())).thenAnswer((
      inv,
    ) {
      final input = inv.positionalArguments[0] as String;
      final digits = input.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 9 && digits.startsWith('7')) {
        return '221$digits';
      }
      return digits;
    });
  });

  Widget buildTestableWidget({required DebtEntity debt}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                WhatsAppReminderBottomSheet.show(
                  context,
                  debt: debt,
                  whatsAppService: mockWhatsAppService,
                  debtRepository: mockDebtRepository,
                );
              },
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );
  }

  group('WhatsAppReminderBottomSheet Widget Tests', () {
    testWidgets('renders initial UI elements with Wolof selected by default', (
      tester,
    ) async {
      final debtor = DebtorEntity(
        id: 'd-1',
        name: 'Modou Fall',
        phoneNumber: '771234567',
        createdAt: testDate,
      );
      final debt = DebtEntity(
        id: 'debt-1',
        debtorId: 'd-1',
        initialAmount: 15000,
        remainingAmount: 15000,
        dueDate: now.add(const Duration(days: 4)),
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: debtor,
      );

      await tester.pumpWidget(buildTestableWidget(debt: debt));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('whatsapp_reminder_bottom_sheet')),
        findsOneWidget,
      );
      expect(find.text('Relance WhatsApp 1-Clic'), findsOneWidget);
      expect(find.text('Modou Fall · Solde dû : 15 000 FCFA'), findsOneWidget);

      expect(
        find.byKey(const ValueKey('whatsapp_phone_input')),
        findsOneWidget,
      );
      expect(find.text('771234567'), findsOneWidget);

      expect(find.byKey(const ValueKey('whatsapp_lang_wolof')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('whatsapp_lang_french')),
        findsOneWidget,
      );

      // Wolof preview by default
      expect(
        find.byKey(const ValueKey('whatsapp_message_preview')),
        findsOneWidget,
      );
      expect(find.textContaining('Salamalekum Modou Fall'), findsOneWidget);

      // Send button touch target >= 48dp
      final sendButtonFinder = find.byKey(
        const ValueKey('whatsapp_send_button'),
      );
      expect(sendButtonFinder, findsOneWidget);
      final size = tester.getSize(sendButtonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('switching language updates message preview dynamically', (
      tester,
    ) async {
      final debtor = DebtorEntity(
        id: 'd-2',
        name: 'Fatou Kiné',
        phoneNumber: '781234567',
        createdAt: testDate,
      );
      final debt = DebtEntity(
        id: 'debt-2',
        debtorId: 'd-2',
        initialAmount: 8000,
        remainingAmount: 8000,
        dueDate: now.subtract(const Duration(days: 2)), // Overdue
        status: DebtStatus.active,
        createdAt: testDate,
        debtor: debtor,
      );

      await tester.pumpWidget(buildTestableWidget(debt: debt));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Wolof initial
      expect(find.textContaining('Salamalekum Fatou Kiné'), findsOneWidget);
      expect(find.text('⚠️ Retard'), findsOneWidget);

      // Switch to French
      await tester.tap(find.byKey(const ValueKey('whatsapp_lang_french')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bonjour Fatou Kiné'), findsOneWidget);
      expect(
        find.textContaining('accord concernant le montant de 8 000 FCFA'),
        findsOneWidget,
      );

      // Switch back to Wolof
      await tester.tap(find.byKey(const ValueKey('whatsapp_lang_wolof')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Salamalekum Fatou Kiné'), findsOneWidget);
    });

    testWidgets(
      'entering invalid or short phone shows error message and prevents send',
      (tester) async {
        final debtor = DebtorEntity(
          id: 'd-3',
          name: 'Client Inconnu',
          phoneNumber: null, // No phone initially
          createdAt: testDate,
        );
        final debt = DebtEntity(
          id: 'debt-3',
          debtorId: 'd-3',
          initialAmount: 5000,
          remainingAmount: 5000,
          dueDate: now.add(const Duration(days: 3)),
          createdAt: testDate,
          debtor: debtor,
        );

        await tester.pumpWidget(buildTestableWidget(debt: debt));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Enter invalid short number
        await tester.enterText(
          find.byKey(const ValueKey('whatsapp_phone_input')),
          '1234',
        );
        await tester.tap(find.byKey(const ValueKey('whatsapp_send_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Veuillez saisir un numéro valide (9 chiffres).'),
          findsOneWidget,
        );
        verifyNever(
          () => mockWhatsAppService.launchWhatsApp(
            phoneNumber: any(named: 'phoneNumber'),
            message: any(named: 'message'),
          ),
        );
      },
    );

    testWidgets(
      'valid phone submission launches WhatsApp, updates debtor and closes sheet',
      (tester) async {
        final debtor = DebtorEntity(
          id: 'd-4',
          name: 'Moussa Ndiaye',
          phoneNumber: null,
          createdAt: testDate,
        );
        final debt = DebtEntity(
          id: 'debt-4',
          debtorId: 'd-4',
          initialAmount: 20000,
          remainingAmount: 20000,
          dueDate: now.add(const Duration(days: 3)),
          createdAt: testDate,
          debtor: debtor,
        );

        when(() => mockDebtRepository.updateDebtor(any())).thenAnswer(
          (_) async => Success(debtor.copyWith(phoneNumber: '221770001122')),
        );
        when(
          () => mockWhatsAppService.launchWhatsApp(
            phoneNumber: any(named: 'phoneNumber'),
            message: any(named: 'message'),
          ),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(buildTestableWidget(debt: debt));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('whatsapp_phone_input')),
          '77 000 11 22',
        );
        await tester.tap(find.byKey(const ValueKey('whatsapp_send_button')));
        await tester.pumpAndSettle();

        verify(
          () => mockDebtRepository.updateDebtor(
            any(
              that: predicate<DebtorEntity>(
                (d) => d.phoneNumber == '221770001122',
              ),
            ),
          ),
        ).called(1);
        verify(
          () => mockWhatsAppService.launchWhatsApp(
            phoneNumber: '221770001122',
            message: any(named: 'message'),
          ),
        ).called(1);

        expect(
          find.byKey(const ValueKey('whatsapp_reminder_bottom_sheet')),
          findsNothing,
        );
        expect(
          find.text('✓ Message de relance préparé dans WhatsApp.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'handles WhatsApp launch failure gracefully with warning SnackBar',
      (tester) async {
        final debtor = DebtorEntity(
          id: 'd-5',
          name: 'Awa Diop',
          phoneNumber: '771112233',
          createdAt: testDate,
        );
        final debt = DebtEntity(
          id: 'debt-5',
          debtorId: 'd-5',
          initialAmount: 10000,
          remainingAmount: 10000,
          dueDate: now.add(const Duration(days: 2)),
          createdAt: testDate,
          debtor: debtor,
        );

        when(
          () => mockWhatsAppService.launchWhatsApp(
            phoneNumber: any(named: 'phoneNumber'),
            message: any(named: 'message'),
          ),
        ).thenAnswer((_) async => false);

        await tester.pumpWidget(buildTestableWidget(debt: debt));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('whatsapp_send_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('whatsapp_error_snackbar')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Impossible d\'ouvrir WhatsApp. Vérifiez que l\'application est bien installée.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
