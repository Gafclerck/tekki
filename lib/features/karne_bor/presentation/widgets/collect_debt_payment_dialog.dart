import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_state.dart';
import 'package:tekki/injection_container.dart';

/// Dialogue modal permettant d'encaisser un remboursement de dette (en totalité ou partiel)
/// avec réconciliation immédiate dans le tiroir-caisse.
class CollectDebtPaymentDialog extends StatelessWidget {
  const CollectDebtPaymentDialog({super.key, required this.debt, this.cubit});

  final DebtEntity debt;
  final CollectDebtPaymentCubit? cubit;

  static Future<DebtPaymentEntity?> show({
    required BuildContext context,
    required DebtEntity debt,
    CollectDebtPaymentCubit? cubit,
  }) {
    return showDialog<DebtPaymentEntity?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CollectDebtPaymentDialog(debt: debt, cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _CollectDebtPaymentView(debt: debt),
      );
    }

    return BlocProvider(
      create: (_) => CollectDebtPaymentCubit(
        debt: debt,
        recordDebtPaymentUseCase: sl<RecordDebtPaymentUseCase>(),
        audioPlayerService: sl.isRegistered<IAudioPlayerService>()
            ? sl<IAudioPlayerService>()
            : null,
      ),
      child: _CollectDebtPaymentView(debt: debt),
    );
  }
}

class _CollectDebtPaymentView extends StatefulWidget {
  const _CollectDebtPaymentView({required this.debt});

  final DebtEntity debt;

  @override
  State<_CollectDebtPaymentView> createState() =>
      _CollectDebtPaymentViewState();
}

class _CollectDebtPaymentViewState extends State<_CollectDebtPaymentView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int _parseAmount(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return 0;
    return int.tryParse(clean) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final debtorName = (widget.debt.debtor?.name.trim().isNotEmpty == true)
        ? widget.debt.debtor!.name.trim()
        : 'Client';

    return BlocConsumer<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      listener: (context, state) {
        if (state.status == CollectDebtPaymentStatus.success) {
          final paidAmount =
              state.createdPayment?.paymentAmount ?? state.effectiveAmount;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                key: const ValueKey('collect_payment_success_snackbar'),
                content: Text(
                  '✅ Encaissement de ${CurrencyFormatter.format(paidAmount)} en espèces enregistré !',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          Navigator.of(context).pop(state.createdPayment);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CollectDebtPaymentCubit>();
        final isSubmitting =
            state.status == CollectDebtPaymentStatus.submitting;

        return Dialog(
          key: const ValueKey('collect_debt_payment_dialog'),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Title & Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Encaisser un paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('close_collect_dialog_button'),
                      icon: const Icon(Icons.close, color: AppColors.secondary),
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Debtor card summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debtorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Solde restant dû',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.debt.remainingAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Option 1: 1-Clic Full Settlement
                Semantics(
                  button: true,
                  label:
                      'Régler le solde complet de ${widget.debt.remainingAmount} FCFA en espèces',
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      key: const ValueKey('collect_full_payment_button'),
                      icon: isSubmitting && state.isFullPayment
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 22),
                      label: Text(
                        'Régler le solde complet (${CurrencyFormatter.format(widget.debt.remainingAmount)})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              cubit.selectFullPayment();
                              cubit.submitPayment();
                            },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Separator
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OU ENCAISSER UN ACOMPTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Custom partial payment input
                TextField(
                  key: const ValueKey('custom_amount_field'),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  enabled: !isSubmitting,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Montant de l\'acompte (FCFA)',
                    hintText: 'Ex: 2 000',
                    suffixText: 'FCFA',
                    errorText: state.errorMessage,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    final amount = _parseAmount(value);
                    cubit.selectCustomPayment(amount);
                  },
                ),

                if (!state.isFullPayment &&
                    state.customAmount > 0 &&
                    state.errorMessage == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Nouveau solde restant : ${CurrencyFormatter.format(state.remainingAfterPayment)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Option 2 Submit Button
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    key: const ValueKey('collect_custom_payment_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        isSubmitting ||
                            state.isFullPayment ||
                            state.customAmount <= 0 ||
                            state.errorMessage != null
                        ? null
                        : () => cubit.submitPayment(),
                    child: isSubmitting && !state.isFullPayment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : const Text(
                            'Valider l\'acompte en espèces',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
