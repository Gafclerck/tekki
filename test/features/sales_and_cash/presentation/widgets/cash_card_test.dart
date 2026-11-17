import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/cash_card.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_button.dart';

void main() {
  Widget buildSubject({required int totalAmount, required int salesCount}) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: CashCard(totalAmount: totalAmount, salesCount: salesCount),
        ),
      ),
    );
  }

  group('CashCard Widget', () {
    testWidgets(
      'renders empty state correctly with exact benevolent message and 0 FCFA',
      (tester) async {
        await tester.pumpWidget(buildSubject(totalAmount: 0, salesCount: 0));

        // Amount display
        final amountFinder = find.byKey(
          const ValueKey('cash_card_total_amount'),
        );
        expect(amountFinder, findsOneWidget);
        expect(tester.widget<Text>(amountFinder).data, equals('0 FCFA'));

        // Exact empty state benevolent message
        final emptyMessageFinder = find.byKey(
          const ValueKey('cash_card_empty_message'),
        );
        expect(emptyMessageFinder, findsOneWidget);
        expect(
          tester.widget<Text>(emptyMessageFinder).data,
          equals(
            "0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse.",
          ),
        );

        // No sales counter badge when empty
        expect(
          find.byKey(const ValueKey('cash_card_sales_counter_badge')),
          findsNothing,
        );

        // Quick sale button is present
        expect(find.byType(QuickSaleButton), findsOneWidget);
        expect(find.text('+ Vente rapide'), findsOneWidget);
      },
    );

    testWidgets(
      'renders active state with 3 sales, formatted amount and badge',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(totalAmount: 17500, salesCount: 3),
        );

        // Formatted amount (17 500 FCFA)
        final amountFinder = find.byKey(
          const ValueKey('cash_card_total_amount'),
        );
        expect(amountFinder, findsOneWidget);
        expect(tester.widget<Text>(amountFinder).data, equals('17 500 FCFA'));

        // Counter badge: "3 ventes"
        final badgeFinder = find.byKey(
          const ValueKey('cash_card_sales_counter_badge'),
        );
        expect(badgeFinder, findsOneWidget);
        expect(find.text('3 ventes'), findsOneWidget);

        // Active note
        final noteFinder = find.byKey(const ValueKey('cash_card_active_note'));
        expect(noteFinder, findsOneWidget);
        expect(
          tester.widget<Text>(noteFinder).data,
          equals("Cumul des ventes enregistrées aujourd'hui"),
        );

        // Quick sale button is present
        expect(find.byType(QuickSaleButton), findsOneWidget);
      },
    );

    testWidgets('renders singular "1 vente" when salesCount is 1', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(totalAmount: 5000, salesCount: 1));

      expect(find.text('1 vente'), findsOneWidget);
    });

    testWidgets('verifies typography and styling constraints', (tester) async {
      await tester.pumpWidget(buildSubject(totalAmount: 25000, salesCount: 2));

      // Check amount text style: 28px, w800, AppColors.primary
      final amountText = tester.widget<Text>(
        find.byKey(const ValueKey('cash_card_total_amount')),
      );
      expect(amountText.style?.fontSize, equals(28));
      expect(amountText.style?.fontWeight, equals(FontWeight.w800));
      expect(amountText.style?.color, equals(AppColors.primary));

      // Check card container decoration: surface background, 1px border AppColors.tertiary, radius 16
      final cardContainer = tester.widget<Container>(
        find.byKey(const ValueKey('cash_card')),
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.surface));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      expect(decoration.border?.top.color, equals(AppColors.tertiary));
      expect(decoration.border?.top.width, equals(1));
    });

    testWidgets(
      'wraps amount in FittedBox with BoxFit.scaleDown to prevent overflow',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(totalAmount: 999999999, salesCount: 50),
        );

        final fittedBoxFinder = find.ancestor(
          of: find.byKey(const ValueKey('cash_card_total_amount')),
          matching: find.byType(FittedBox),
        );
        expect(fittedBoxFinder, findsOneWidget);

        final fittedBox = tester.widget<FittedBox>(fittedBoxFinder);
        expect(fittedBox.fit, equals(BoxFit.scaleDown));
        expect(fittedBox.alignment, equals(Alignment.centerLeft));
      },
    );
  });
}
