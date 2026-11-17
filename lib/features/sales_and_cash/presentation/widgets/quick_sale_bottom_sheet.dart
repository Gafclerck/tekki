import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_state.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/quick_sale_keypad.dart';

class QuickSaleBottomSheet extends StatelessWidget {
  const QuickSaleBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuickSaleCubit, QuickSaleState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == QuickSaleStatus.success) {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop(state.createdSale);
        } else if (state.status == QuickSaleStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? "Échec de l'enregistrement de la vente.",
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<QuickSaleCubit>();

        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vente rapide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Amount Display (Lisible à 1 mètre)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tertiary, width: 1),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Montant à encaisser',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(state.amount),
                          key: const ValueKey('quick_sale_amount_display'),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Payment Method Selector
                  _PaymentMethodSelector(
                    selectedMethod: state.paymentMethod,
                    onChanged: cubit.setPaymentMethod,
                  ),
                  const SizedBox(height: 10),

                  // Keypad
                  QuickSaleKeypad(
                    onDigitPressed: cubit.appendDigit,
                    onDeletePressed: cubit.deleteDigit,
                    onClearPressed: cubit.clear,
                  ),
                  const SizedBox(height: 14),

                  // Validation CTA Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const ValueKey('quick_sale_submit_button'),
                      onPressed: state.canSubmit
                          ? () {
                              HapticFeedback.lightImpact();
                              cubit.submit();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.tertiary.withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: state.canSubmit ? 2 : 0,
                      ),
                      child: state.status == QuickSaleStatus.submitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              state.amount > 0
                                  ? 'Valider (${CurrencyFormatter.format(state.amount)})'
                                  : "Valider l'encaissement",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onChanged,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodOption(
            label: 'Espèces',
            icon: Icons.money,
            isSelected: selectedMethod == PaymentMethod.especes,
            key: const ValueKey('payment_method_especes'),
            onTap: () => onChanged(PaymentMethod.especes),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MethodOption(
            label: 'Mobile Money',
            icon: Icons.phone_android,
            isSelected: selectedMethod == PaymentMethod.mobileMoney,
            key: const ValueKey('payment_method_mobile_money'),
            onTap: () => onChanged(PaymentMethod.mobileMoney),
          ),
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.tertiary,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
