import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';

/// Composant d'affichage d'une créance client dans le Karné Bor.
///
/// Respecte les spécifications DESIGN.md et la maquette `key-karne-bor.html` :
/// - Nom du débiteur (avec repli robuste) et solde restant dû lisible
/// - Date d'échéance formatée et badge de retard en cas de dépassement
/// - Mention du montant initial si remboursement partiel
/// - Cibles tactiles d'actions >= 48dp x 48dp pour encaissement et relance WhatsApp
class DebtCard extends StatelessWidget {
  const DebtCard({
    super.key,
    required this.debt,
    this.onCollect,
    this.onReminder,
  });

  final DebtEntity debt;
  final VoidCallback? onCollect;
  final VoidCallback? onReminder;

  @override
  Widget build(BuildContext context) {
    final isLate = debt.isOverdue;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasPartialPayment = debt.remainingAmount < debt.initialAmount;
    final debtorName = (debt.debtor?.name.trim().isNotEmpty == true)
        ? debt.debtor!.name.trim()
        : 'Client';

    return Container(
      key: key ?? ValueKey('debt_card_${debt.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLate
              ? AppColors.accent
              : AppColors.tertiary.withValues(alpha: 0.4),
          width: isLate ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Customer name & Remaining Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  debtorName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.format(debt.remainingAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (hasPartialPayment) ...[
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Solde restant sur ${CurrencyFormatter.format(debt.initialAmount)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Meta: Due date & status badge
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '⚠️ Retard',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
          const SizedBox(height: 12),

          // Action buttons: Preparation for Stories 2.3 & 2.4 (touch target >= 48dp)
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Relancer le client $debtorName sur WhatsApp',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: OutlinedButton(
                      key: ValueKey('debt_card_reminder_button_${debt.id}'),
                      onPressed: () {
                        if (onReminder != null) {
                          onReminder!();
                        } else {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La relance WhatsApp sera disponible avec la Story 2.4.',
                                ),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        '💬 Relance WhatsApp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Encaisser le paiement de $debtorName',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: ElevatedButton(
                      key: ValueKey('debt_card_collect_button_${debt.id}'),
                      onPressed: () {
                        if (onCollect != null) {
                          onCollect!();
                        } else {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "L'encaissement de créance sera disponible avec la Story 2.3.",
                                ),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        '✓ Encaisser',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
