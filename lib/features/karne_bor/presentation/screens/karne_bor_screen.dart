import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/widgets/record_debt_bottom_sheet.dart';
import 'package:tekki/injection_container.dart';

class KarneBorScreen extends StatefulWidget {
  const KarneBorScreen({
    super.key,
    this.karneBorCubit,
    this.recordDebtCubit,
  });

  final KarneBorCubit? karneBorCubit;
  final RecordDebtCubit? recordDebtCubit;

  @override
  State<KarneBorScreen> createState() => _KarneBorScreenState();
}

class _KarneBorScreenState extends State<KarneBorScreen> {
  late final KarneBorCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.karneBorCubit ??
        (sl.isRegistered<KarneBorCubit>()
            ? sl<KarneBorCubit>()
            : KarneBorCubit(watchActiveDebtsUseCase: sl()));
    _cubit.startWatching();
  }

  @override
  void dispose() {
    if (widget.karneBorCubit == null) {
      _cubit.close();
    }
    super.dispose();
  }

  Future<void> _openRecordDebtSheet() async {
    RecordDebtCubit debtCubit;
    if (widget.recordDebtCubit != null) {
      debtCubit = widget.recordDebtCubit!;
    } else if (sl.isRegistered<RecordDebtCubit>()) {
      debtCubit = sl<RecordDebtCubit>();
    } else {
      debtCubit = RecordDebtCubit(
        recordDebtUseCase: sl(),
        getDebtorsUseCase: sl(),
      );
    }

    await RecordDebtBottomSheet.show(
      context,
      cubit: debtCubit,
      onDebtRecorded: (debt) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const ValueKey('debt_recorded_snackbar'),
            content: Text(
              '✓ Dette enregistrée pour ${debt.debtor?.name ?? 'le client'} (${CurrencyFormatter.format(debt.remainingAmount)}).',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    if (widget.recordDebtCubit == null) {
      await debtCubit.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        key: const ValueKey('karne_bor_screen'),
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            key: const ValueKey('karne_bor_back_button'),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carnet Numérique',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Karné Bor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<KarneBorCubit, KarneBorState>(
            builder: (context, state) {
              if (state is KarneBorLoading || state is KarneBorInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is KarneBorError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final loaded = state as KarneBorLoaded;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Banner: Argent Dehors
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildSummaryCard(loaded.totalDebt, loaded.debts.length),
                  ),

                  // Content: list or empty state
                  Expanded(
                    child: loaded.debts.isEmpty
                        ? _buildEmptyState()
                        : _buildDebtsList(loaded.debts),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                key: const ValueKey('add_debt_button'),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  '+ Noter une Dette Client',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _openRecordDebtSheet,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalDebt, int debtsCount) {
    return Container(
      key: const ValueKey('karne_bor_summary_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ARGENT DEHORS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(totalDebt),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$debtsCount créance${debtsCount > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          key: const ValueKey('karne_bor_empty_state'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentSoft.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun argent dehors !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aucun argent dehors ! Vos créances sont toutes à jour.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsList(List<DebtEntity> debts) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView.separated(
      key: const ValueKey('karne_bor_debts_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: debts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final debt = debts[index];
        final isLate = debt.isOverdue;

        return Container(
          key: ValueKey('debt_card_${debt.id}'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLate ? AppColors.accent : AppColors.tertiary.withValues(alpha: 0.4),
              width: isLate ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      debt.debtor?.name ?? 'Client',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(debt.remainingAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Échéance : ${dateFormat.format(debt.dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLate ? AppColors.accent : AppColors.secondary,
                    ),
                  ),
                  if (isLate)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⚠️ Retard',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'À jour',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
