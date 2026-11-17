import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_state.dart';

class RecordDebtBottomSheet extends StatefulWidget {
  const RecordDebtBottomSheet({super.key, this.onDebtRecorded});

  final ValueChanged<DebtEntity>? onDebtRecorded;

  static Future<DebtEntity?> show(
    BuildContext context, {
    RecordDebtCubit? cubit,
    ValueChanged<DebtEntity>? onDebtRecorded,
  }) {
    return showModalBottomSheet<DebtEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final content = RecordDebtBottomSheet(onDebtRecorded: onDebtRecorded);
        if (cubit != null) {
          return BlocProvider<RecordDebtCubit>.value(
            value: cubit,
            child: content,
          );
        }
        return content;
      },
    );
  }

  @override
  State<RecordDebtBottomSheet> createState() => _RecordDebtBottomSheetState();
}

class _RecordDebtBottomSheetState extends State<RecordDebtBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedDebtorId;
  List<DebtorEntity> _knownDebtors = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RecordDebtCubit?>();
    cubit?.loadDebtors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onQuickDateSelected(Duration offset) {
    setState(() {
      _dueDate = DateTime.now().add(offset);
    });
  }

  void _onFridaySelected() {
    final now = DateTime.now();
    // Friday is weekday 5
    int daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    if (daysUntilFriday <= 0) daysUntilFriday += 7;
    setState(() {
      _dueDate = now.add(Duration(days: daysUntilFriday));
    });
  }

  void _onEndOfMonthSelected() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _dueDate = lastDay;
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Date d\'échéance du remboursement',
      confirmText: 'Choisir',
      cancelText: 'Annuler',
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _selectDebtor(DebtorEntity debtor) {
    setState(() {
      _selectedDebtorId = debtor.id;
      _nameController.text = debtor.name;
      if (debtor.phoneNumber != null) {
        _phoneController.text = debtor.phoneNumber!;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(
      _amountController.text.replaceAll(RegExp(r'\s+'), ''),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant doit être un entier positif en FCFA.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    context.read<RecordDebtCubit>().submit(
      debtorName: _nameController.text.trim(),
      debtorPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      amount: amount,
      dueDate: _dueDate,
      existingDebtorId: _selectedDebtorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocConsumer<RecordDebtCubit, RecordDebtState>(
      listener: (context, state) {
        if (state is RecordDebtInitial) {
          setState(() {
            _knownDebtors = state.knownDebtors;
          });
        } else if (state is RecordDebtSuccess) {
          widget.onDebtRecorded?.call(state.debt);
          Navigator.of(context).pop(state.debt);
        } else if (state is RecordDebtFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const ValueKey('record_debt_error_snack'),
              content: Text(state.message),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is RecordDebtSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            key: const ValueKey('record_debt_bottom_sheet'),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
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
                      const SizedBox(height: 12),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Karné Bor',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                'Noter une Dette Client',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            key: const ValueKey('close_record_debt_button'),
                            icon: const Icon(Icons.close),
                            color: AppColors.primary,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Known debtors quick selection (if any)
                      if (_knownDebtors.isNotEmpty) ...[
                        const Text(
                          'Clients récents',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _knownDebtors.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final debtor = _knownDebtors[index];
                              final isSelected = debtor.id == _selectedDebtorId;
                              return ActionChip(
                                label: Text(debtor.name),
                                backgroundColor: isSelected
                                    ? AppColors.accentSoft
                                    : AppColors.background,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                ),
                                onPressed: () => _selectDebtor(debtor),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Client Name
                      TextFormField(
                        key: const ValueKey('debtor_name_input'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_selectedDebtorId != null) {
                            setState(() {
                              _selectedDebtorId = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Nom du client *',
                          hintText: 'Ex: Fatou Kiné, Modou Fall',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez renseigner le nom du client.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Client Phone (Optional)
                      TextFormField(
                        key: const ValueKey('debtor_phone_input'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Numéro WhatsApp / Téléphone (optionnel)',
                          hintText: 'Ex: 77 123 45 67',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount in FCFA
                      TextFormField(
                        key: const ValueKey('debt_amount_input'),
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Montant du crédit *',
                          hintText: '0',
                          suffixText: 'FCFA',
                          suffixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                          prefixIcon: const Icon(Icons.payments_outlined),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un montant.';
                          }
                          final parsed = int.tryParse(
                            value.replaceAll(RegExp(r'\s+'), ''),
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'Le montant doit être supérieur à 0 FCFA.';
                          }
                          if (parsed > 999999999) {
                            return 'Le montant dépasse le plafond autorisé (999 999 999 FCFA).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due date selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date d\'échéance convenue',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          TextButton.icon(
                            key: const ValueKey('pick_custom_date_button'),
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: Text(
                              dateFormat.format(_dueDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: _pickCustomDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Quick due date chips
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Dans 3 jours'),
                            selected: false,
                            onSelected: (_) =>
                                _onQuickDateSelected(const Duration(days: 3)),
                          ),
                          ChoiceChip(
                            label: const Text('Vendredi'),
                            selected: false,
                            onSelected: (_) => _onFridaySelected(),
                          ),
                          ChoiceChip(
                            label: const Text('Dans 7 jours'),
                            selected: false,
                            onSelected: (_) =>
                                _onQuickDateSelected(const Duration(days: 7)),
                          ),
                          ChoiceChip(
                            label: const Text('Fin du mois'),
                            selected: false,
                            onSelected: (_) => _onEndOfMonthSelected(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          key: const ValueKey('submit_debt_button'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  '✓ Enregistrer la Dette',
                                  style: TextStyle(
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
            ),
          ),
        );
      },
    );
  }
}
