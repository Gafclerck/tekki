import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';
import 'package:tekki/features/financing/domain/usecases/submit_loan_application_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/loan_application_form_cubit.dart';
import 'package:tekki/features/financing/presentation/cubit/loan_application_form_state.dart';
import 'package:tekki/injection_container.dart';

class LoanRequestSheet extends StatelessWidget {
  const LoanRequestSheet({
    super.key,
    required this.partners,
    required this.currentScore,
    this.shopId = 'default-shop',
    this.onSubmitted,
  });

  final List<FinancialPartnerEntity> partners;
  final int currentScore;
  final String shopId;
  final void Function(LoanApplicationEntity application)? onSubmitted;

  static Future<void> show(
    BuildContext context, {
    required List<FinancialPartnerEntity> partners,
    required int currentScore,
    FinancialPartnerEntity? preselectedPartner,
    int? preselectedAmount,
    String shopId = 'default-shop',
    void Function(LoanApplicationEntity application)? onSubmitted,
    LoanApplicationFormCubit? cubit,
    SubmitLoanApplicationUseCase? submitLoanApplicationUseCase,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        if (cubit != null) {
          return BlocProvider.value(
            value: cubit,
            child: LoanRequestSheet(
              partners: partners,
              currentScore: currentScore,
              shopId: shopId,
              onSubmitted: onSubmitted,
            ),
          );
        }

        final useCase =
            submitLoanApplicationUseCase ??
            (sl.isRegistered<SubmitLoanApplicationUseCase>()
                ? sl<SubmitLoanApplicationUseCase>()
                : SubmitLoanApplicationUseCase(
                    repository: sl.isRegistered<LoanApplicationRepository>()
                        ? sl<LoanApplicationRepository>()
                        : const _FallbackLoanApplicationRepository(),
                  ));

        return BlocProvider(
          create: (_) => LoanApplicationFormCubit(
            submitLoanApplicationUseCase: useCase,
            initialPartner:
                preselectedPartner ??
                (partners.isNotEmpty ? partners.first : null),
            initialAmount: preselectedAmount ?? 500000,
          ),
          child: LoanRequestSheet(
            partners: partners,
            currentScore: currentScore,
            shopId: shopId,
            onSubmitted: onSubmitted,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanApplicationFormCubit, LoanApplicationFormState>(
      listener: (context, state) {
        if (state.isSuccess && state.submittedApplication != null) {
          Navigator.of(context).pop();
          if (onSubmitted != null) {
            onSubmitted!(state.submittedApplication!);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const ValueKey('loan_request_success_snackbar'),
              content: Text(
                '✓ Demande de prêt de ${CurrencyFormatter.format(state.submittedApplication!.requestedAmount)} envoyée à ${state.submittedApplication!.partnerName} !',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoanApplicationFormCubit>();

        return Material(
          key: const ValueKey('loan_request_sheet'),
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Demande de Financement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Error banner
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 1. Choix du Partenaire
                  const Text(
                    '1. Partenaire Financier',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<FinancialPartnerEntity>(
                    key: const ValueKey('partner_dropdown'),
                    initialValue:
                        state.selectedPartner ??
                        (partners.isNotEmpty ? partners.first : null),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: partners.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.name} (${p.typeDisplayName})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) cubit.setPartner(p);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Montant souhaité
                  const Text(
                    '2. Montant Souhaité (FCFA)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [250000, 500000, 1000000, 1500000, 2500000].map((
                      amount,
                    ) {
                      final isSelected = state.requestedAmount == amount;
                      return ChoiceChip(
                        key: ValueKey('amount_chip_$amount'),
                        label: Text(CurrencyFormatter.format(amount)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) => cubit.setAmount(amount),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. Durée de remboursement
                  const Text(
                    '3. Durée de remboursement (Mois)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [3, 6, 9, 12, 18].map((months) {
                      final isSelected = state.durationMonths == months;
                      return ChoiceChip(
                        key: ValueKey('duration_chip_$months'),
                        label: Text('$months mois'),
                        selected: isSelected,
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) => cubit.setDuration(months),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 4. Objet du financement
                  const Text(
                    '4. Objet du prêt',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<LoanPurpose>(
                    key: const ValueKey('purpose_dropdown'),
                    initialValue: state.purpose,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: LoanPurpose.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          p.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) cubit.setPurpose(p);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Simulation Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mensualité estimée :',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              'Taux indicatif partenaire',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${CurrencyFormatter.format(state.estimatedMonthlyPayment)} / mois',
                          key: const ValueKey('estimated_monthly_payment_text'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Consentement Passeport
                  CheckboxListTile(
                    key: const ValueKey('consent_checkbox'),
                    value: state.consentSharePassport,
                    onChanged: (val) => cubit.toggleConsent(val ?? true),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      'J\'autorise le partage de mon Passeport Financier Tekki certifié (Score: $currentScore/100, historique des clôtures) avec l\'institution.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton.icon(
                    key: const ValueKey('submit_loan_request_button'),
                    onPressed: state.isSubmitting
                        ? null
                        : () => cubit.submit(
                            shopId: shopId,
                            currentScore: currentScore,
                          ),
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      state.isSubmitting
                          ? 'Transmission en cours...'
                          : 'Soumettre ma demande',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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

class _FallbackLoanApplicationRepository implements LoanApplicationRepository {
  const _FallbackLoanApplicationRepository();

  @override
  Future<Result<LoanApplicationEntity, Failure>> submitApplication(
    LoanApplicationEntity application,
  ) async => Result.success(application);

  @override
  Stream<List<LoanApplicationEntity>> watchApplications({
    required String shopId,
  }) => Stream.value(const []);

  @override
  Future<List<LoanApplicationEntity>> getApplications({
    required String shopId,
  }) async => const [];
}
