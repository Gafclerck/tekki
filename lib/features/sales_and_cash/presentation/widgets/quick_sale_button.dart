import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_bottom_sheet.dart';
import 'package:tekki/injection_container.dart';

Future<SaleEntity?> showQuickSaleModal(BuildContext context) {
  return showModalBottomSheet<SaleEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocProvider(
      create: (_) => sl<QuickSaleCubit>(),
      child: const QuickSaleBottomSheet(),
    ),
  );
}

class QuickSaleButton extends StatelessWidget {
  const QuickSaleButton({
    super.key,
    this.onSaleRecorded,
  });

  final ValueChanged<SaleEntity>? onSaleRecorded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // Touch target floor >= 48dp
      child: OutlinedButton.icon(
        key: const ValueKey('quick_sale_open_button'),
        icon: const Icon(Icons.bolt, size: 20, color: AppColors.secondary),
        label: const Text(
          '+ Vente rapide',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () async {
          final sale = await showQuickSaleModal(context);
          if (sale != null && context.mounted) {
            onSaleRecorded?.call(sale);
          }
        },
      ),
    );
  }
}
