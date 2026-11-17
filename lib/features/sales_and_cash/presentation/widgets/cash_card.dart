import 'package:flutter/material.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_button.dart';

class CashCard extends StatelessWidget {
  const CashCard({
    super.key,
    required this.totalAmount,
    required this.salesCount,
    this.onSaleRecorded,
  });

  final int totalAmount;
  final int salesCount;
  final ValueChanged<SaleEntity>? onSaleRecorded;

  static const String emptyStateMessage =
      "0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse.";

  @override
  Widget build(BuildContext context) {
    final hasSales = salesCount > 0;

    return Container(
      key: const ValueKey('cash_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Caisse du jour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (hasSales)
                Container(
                  key: const ValueKey('cash_card_sales_counter_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.tertiary, width: 1),
                  ),
                  child: Text(
                    '$salesCount ${salesCount > 1 ? 'ventes' : 'vente'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Display Amount (28px bold 800)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(totalAmount),
              key: const ValueKey('cash_card_total_amount'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle / Informative note
          Text(
            hasSales
                ? "Cumul des ventes enregistrées aujourd'hui"
                : emptyStateMessage,
            key: hasSales
                ? const ValueKey('cash_card_active_note')
                : const ValueKey('cash_card_empty_message'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Sale Action
          QuickSaleButton(onSaleRecorded: onSaleRecorded),
        ],
      ),
    );
  }
}
