import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_bottom_sheet.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_button.dart';
import 'package:tekki/injection_container.dart';

class MockRecordQuickSaleUseCase extends Mock
    implements RecordQuickSaleUseCase {}

void main() {
  late MockRecordQuickSaleUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockRecordQuickSaleUseCase();
  });

  Widget buildTestWidget({QuickSaleCubit? cubit}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: BlocProvider<QuickSaleCubit>(
          create: (_) =>
              cubit ?? QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
          child: const QuickSaleBottomSheet(),
        ),
      ),
    );
  }

  group('QuickSaleBottomSheet & Keypad UI', () {
    testWidgets('renders all initial UI elements correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Title
      expect(find.text('Vente rapide'), findsOneWidget);

      // Initial Amount display (0 FCFA)
      expect(
        find.byKey(const ValueKey('quick_sale_amount_display')),
        findsOneWidget,
      );
      expect(find.textContaining('0 FCFA'), findsOneWidget);

      // Payment options
      expect(find.text('Espèces'), findsOneWidget);
      expect(find.text('Mobile Money'), findsOneWidget);

      // Validation button is disabled when amount is 0
      final submitButtonFinder = find.byKey(
        const ValueKey('quick_sale_submit_button'),
      );
      expect(submitButtonFinder, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(submitButtonFinder);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('keypad numeric keys have height >= 60dp', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      for (int i = 0; i <= 9; i++) {
        final keyFinder = find.byKey(ValueKey('keypad_$i'));
        expect(keyFinder, findsOneWidget);
        final size = tester.getSize(keyFinder);
        expect(size.height, greaterThanOrEqualTo(60.0));
      }
    });

    testWidgets(
      'tapping digits updates amount display and enables submit button',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Tap 2, 5, 0, 0 -> 2 500 F CFA
        await tester.tap(find.byKey(const ValueKey('keypad_2')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('keypad_5')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('keypad_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('keypad_0')));
        await tester.pump();

        expect(find.textContaining('2 500 FCFA'), findsWidgets);

        final submitButton = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('quick_sale_submit_button')),
        );
        expect(submitButton.onPressed, isNotNull);
      },
    );

    testWidgets('tapping backspace removes last digit', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byKey(const ValueKey('keypad_2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_5')));
      await tester.pump();

      expect(find.textContaining('25 FCFA'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('keypad_backspace')));
      await tester.pump();

      expect(find.textContaining('2 FCFA'), findsWidgets);
    });

    testWidgets('switching payment method updates selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap Mobile Money
      await tester.tap(
        find.byKey(const ValueKey('payment_method_mobile_money')),
      );
      await tester.pump();

      // Mobile money is selected
      final mmFinder = find.byKey(
        const ValueKey('payment_method_mobile_money'),
      );
      expect(mmFinder, findsOneWidget);
    });

    testWidgets('validating submission calls useCase and pops on success', (
      tester,
    ) async {
      final createdSale = SaleEntity(
        id: 'sale-123',
        amount: 2500,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime.now().toUtc(),
      );

      when(
        () => mockUseCase(amount: 2500, paymentMethod: PaymentMethod.especes),
      ).thenAnswer((_) async => Success(createdSale));

      SaleEntity? poppedResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    poppedResult = await showModalBottomSheet<SaleEntity>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => BlocProvider<QuickSaleCubit>(
                        create: (_) =>
                            QuickSaleCubit(recordQuickSaleUseCase: mockUseCase),
                        child: const QuickSaleBottomSheet(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Vente rapide'), findsOneWidget);

      // Type 2 5 0 0
      await tester.tap(find.byKey(const ValueKey('keypad_2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_5')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_0')));
      await tester.pump();

      // Tap Submit
      await tester.tap(find.byKey(const ValueKey('quick_sale_submit_button')));
      await tester.pumpAndSettle();

      // Modal closed and result returned
      expect(find.text('Vente rapide'), findsNothing);
      expect(poppedResult, equals(createdSale));
    });

    testWidgets('QuickSaleButton opens bottom sheet via get_it', (
      tester,
    ) async {
      // Register in GetIt for this test
      if (sl.isRegistered<RecordQuickSaleUseCase>()) {
        sl.unregister<RecordQuickSaleUseCase>();
      }
      if (sl.isRegistered<QuickSaleCubit>()) {
        sl.unregister<QuickSaleCubit>();
      }
      sl.registerLazySingleton<RecordQuickSaleUseCase>(() => mockUseCase);
      sl.registerFactory<QuickSaleCubit>(
        () => QuickSaleCubit(recordQuickSaleUseCase: sl()),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Center(child: QuickSaleButton())),
        ),
      );

      expect(find.text('+ Vente rapide'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quick_sale_open_button')));
      await tester.pumpAndSettle();

      expect(find.text('Vente rapide'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quick_sale_amount_display')),
        findsOneWidget,
      );
    });
  });
}
