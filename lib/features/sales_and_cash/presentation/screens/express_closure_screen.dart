import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_state.dart';
import 'package:tekki/injection_container.dart';

class ExpressClosureScreen extends StatelessWidget {
  const ExpressClosureScreen({
    super.key,
    this.cubit,
    this.audioPlayerService,
    this.onClosureSuccess,
  });

  final ExpressClosureCubit? cubit;
  final IAudioPlayerService? audioPlayerService;
  final void Function(DailyClosureEntity closure)? onClosureSuccess;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _ExpressClosureView(
          audioPlayerService: audioPlayerService,
          onClosureSuccess: onClosureSuccess,
        ),
      );
    }
    if (sl.isRegistered<ExpressClosureCubit>()) {
      return BlocProvider(
        create: (_) => sl<ExpressClosureCubit>()..init(),
        child: _ExpressClosureView(
          audioPlayerService: audioPlayerService,
          onClosureSuccess: onClosureSuccess,
        ),
      );
    }
    return _ExpressClosureView(
      audioPlayerService: audioPlayerService,
      onClosureSuccess: onClosureSuccess,
    );
  }
}

class _ExpressClosureView extends StatefulWidget {
  const _ExpressClosureView({this.audioPlayerService, this.onClosureSuccess});

  final IAudioPlayerService? audioPlayerService;
  final void Function(DailyClosureEntity closure)? onClosureSuccess;

  @override
  State<_ExpressClosureView> createState() => _ExpressClosureViewState();
}

class _ExpressClosureViewState extends State<_ExpressClosureView> {
  late final TextEditingController _salesController;
  late final TextEditingController _expensesController;
  late final TextEditingController _cashCountedController;
  bool _salesFieldModified = false;

  @override
  void initState() {
    super.initState();
    _salesController = TextEditingController(text: '0');
    _expensesController = TextEditingController(text: '0');
    _cashCountedController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _salesController.dispose();
    _expensesController.dispose();
    _cashCountedController.dispose();
    super.dispose();
  }

  int _parseAmount(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return 0;
    return int.tryParse(clean) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Check if cubit exists in context
    ExpressClosureCubit? cubit;
    try {
      cubit = context.read<ExpressClosureCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit == null) {
      return _buildScaffold(
        context: context,
        state: ExpressClosureState.initial(),
        cubit: null,
      );
    }

    return BlocConsumer<ExpressClosureCubit, ExpressClosureState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.prefilledSalesAmount != current.prefilledSalesAmount;
      },
      listener: (context, state) {
        if (state.status == ExpressClosureStatus.ready &&
            !_salesFieldModified) {
          _salesController.text = state.totalSalesAmount.toString();
        }
        if (state.status == ExpressClosureStatus.success &&
            state.createdClosure != null) {
          try {
            final audio =
                widget.audioPlayerService ??
                (sl.isRegistered<IAudioPlayerService>()
                    ? sl<IAudioPlayerService>()
                    : null);
            audio?.playCashDrawerSound();
          } catch (_) {}

          try {
            HapticFeedback.mediumImpact();
          } catch (_) {}

          widget.onClosureSuccess?.call(state.createdClosure!);

          final streakMsg = state.activeStreak > 0
              ? ' · Série : ${state.activeStreak} jour${state.activeStreak > 1 ? "s" : ""}'
              : '';
          final monthlyMsg = state.monthlyClosuresCount > 0
              ? ' · ${state.monthlyClosuresCount} ce mois'
              : '';

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const ValueKey('closure_success_snackbar'),
              content: Text(
                '✅ Caisse clôturée et verrouillée avec succès !$streakMsg$monthlyMsg',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).maybePop(state.createdClosure);
        }
      },
      builder: (context, state) {
        return _buildScaffold(context: context, state: state, cubit: cubit);
      },
    );
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName ${dt.day} $monthName';
  }

  Widget _buildScaffold({
    required BuildContext context,
    required ExpressClosureState state,
    required ExpressClosureCubit? cubit,
  }) {
    final capitalizedDate = _formatDate(state.cutoffTimestamp.toLocal());

    final isSubmitting = state.status == ExpressClosureStatus.submitting;

    return Scaffold(
      key: const ValueKey('express_closure_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            key: const ValueKey('back_button'),
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.tertiary, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset(
                  'assets/branding/logo_symbol.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clôture de Caisse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$capitalizedDate · Fin de service',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer & reassurance banner
              _buildTimerBadge(state.currentStep),
              const SizedBox(height: 14),

              // Error banner if any
              if (state.errorMessage != null) ...[
                _buildErrorBanner(state.errorMessage!),
                const SizedBox(height: 14),
              ],

              // STEP 1 : Total Encaissé Aujourd'hui
              _buildInputBlock(
                key: const ValueKey('step_1_card'),
                stepNumber: '1',
                label: 'Total Encaissé Aujourd’hui',
                hint: state.prefilledSalesAmount > 0
                    ? 'Inclut ${state.prefilledSalesAmount} FCFA enregistrés au fil de l’eau'
                    : 'Pré-rempli avec les ventes du jour. Ajustable au besoin.',
                controller: _salesController,
                inputKey: const ValueKey('sales_input_field'),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  _salesFieldModified = true;
                  final amount = _parseAmount(val);
                  cubit?.setTotalSales(amount);
                },
                onFocus: () => cubit?.setStep(1),
              ),
              const SizedBox(height: 14),

              // STEP 2 : Dépenses d'exploitation
              _buildInputBlock(
                key: const ValueKey('step_2_card'),
                stepNumber: '2',
                label: 'Dépenses / Achats du Jour',
                hint: 'Ex: Pain, réassort, glace, petits frais (défaut 0 FCFA)',
                controller: _expensesController,
                inputKey: const ValueKey('expenses_input_field'),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  final amount = _parseAmount(val);
                  cubit?.setTotalExpenses(amount);
                },
                onFocus: () => cubit?.setStep(2),
              ),
              const SizedBox(height: 14),

              // STEP 3 : Espèces en caisse à la fermeture
              _buildInputBlock(
                key: const ValueKey('step_3_card'),
                stepNumber: '3',
                label: 'Espèces en Caisse à la Fermeture',
                hint: 'Espèces physiques réelles + soldes Mobile Money',
                controller: _cashCountedController,
                inputKey: const ValueKey('cash_counted_input_field'),
                textInputAction: TextInputAction.done,
                onChanged: (val) {
                  final amount = _parseAmount(val);
                  cubit?.setCashCounted(amount);
                },
                onFocus: () => cubit?.setStep(3),
              ),
              const SizedBox(height: 16),

              // Streak banner
              _buildStreakBanner(state),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.tertiary.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: ElevatedButton(
            key: const ValueKey('button-validate-closure'),
            onPressed: (state.canSubmit && !isSubmitting && cubit != null)
                ? () {
                    HapticFeedback.mediumImpact();
                    cubit.submitClosure();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✅ '),
                      Text(
                        'Valider et Verrouiller la Caisse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBadge(int step) {
    return Container(
      key: const ValueKey('timer_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tertiary, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text('⏱️ ', style: TextStyle(fontSize: 14)),
              Text(
                'Objectif : ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '< 30 secondes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Étape $step/3',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      key: const ValueKey('closure_error_banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBlock({
    required Key key,
    required String stepNumber,
    required String label,
    required String hint,
    required TextEditingController controller,
    required Key inputKey,
    required ValueChanged<String> onChanged,
    required VoidCallback onFocus,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber. $label',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  key: inputKey,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: textInputAction,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                  onTap: onFocus,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'FCFA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(fontSize: 11, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner(ExpressClosureState state) {
    final streak = state.activeStreak;
    final monthly = state.monthlyClosuresCount;

    final String title;
    final String subtitle;

    if (streak > 0) {
      title = 'Clôture quotidienne · Série active ($streak j) !';
      subtitle =
          '$streak jour${streak > 1 ? "s" : ""} consécutif${streak > 1 ? "s" : ""} · $monthly clôture${monthly > 1 ? "s" : ""} ce mois-ci';
    } else if (monthly > 0) {
      title = 'Clôture quotidienne · Série active !';
      subtitle =
          '$monthly clôture${monthly > 1 ? "s" : ""} ce mois-ci · Démarrez votre série !';
    } else {
      title = 'Clôture quotidienne · Série active !';
      subtitle = 'Ancrage GPS conforme · Passeport Financier mis à jour.';
    }

    return Container(
      key: const ValueKey('streak_banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
                if (streak > 0 || monthly > 0) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Ancrage GPS conforme · Passeport Financier mis à jour.',
                    style: TextStyle(fontSize: 10, color: AppColors.secondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
