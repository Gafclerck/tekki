import 'package:flutter/material.dart';
import 'package:tekki/core/services/whatsapp_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/currency_formatter.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/services/whatsapp_reminder_template.dart';
import 'package:tekki/injection_container.dart';

/// Feuille modale de relance client 1-clic via WhatsApp.
///
/// Permet de :
/// - Choisir la langue du message (Wolof ou Français, Wolof par défaut)
/// - Prévisualiser le texte bienveillant et respectueux de la culture (Teranga, Soutoura)
/// - Saisir ou modifier le numéro de téléphone sans bloquer
/// - Déclencher l'ouverture de WhatsApp avec capture gracieuse d'erreur
class WhatsAppReminderBottomSheet extends StatefulWidget {
  const WhatsAppReminderBottomSheet({
    super.key,
    required this.debt,
    this.whatsAppService,
    this.debtRepository,
  });

  final DebtEntity debt;
  final IWhatsAppService? whatsAppService;
  final DebtRepository? debtRepository;

  static Future<bool?> show(
    BuildContext context, {
    required DebtEntity debt,
    IWhatsAppService? whatsAppService,
    DebtRepository? debtRepository,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WhatsAppReminderBottomSheet(
        debt: debt,
        whatsAppService: whatsAppService,
        debtRepository: debtRepository,
      ),
    );
  }

  @override
  State<WhatsAppReminderBottomSheet> createState() =>
      _WhatsAppReminderBottomSheetState();
}

class _WhatsAppReminderBottomSheetState
    extends State<WhatsAppReminderBottomSheet> {
  late final TextEditingController _phoneController;
  late final IWhatsAppService _whatsAppService;
  late final DebtRepository? _debtRepository;

  WhatsAppReminderLanguage _selectedLanguage = WhatsAppReminderLanguage.wolof;
  String? _phoneError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.debt.debtor?.phoneNumber ?? '',
    );
    _whatsAppService =
        widget.whatsAppService ??
        (sl.isRegistered<IWhatsAppService>()
            ? sl<IWhatsAppService>()
            : const UrlLauncherWhatsAppService());
    _debtRepository =
        widget.debtRepository ??
        (sl.isRegistered<DebtRepository>() ? sl<DebtRepository>() : null);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _buildPreviewMessage() {
    final debtorName = widget.debt.debtor?.name ?? '';
    return WhatsAppReminderTemplate.generate(
      debtorName: debtorName,
      remainingAmount: widget.debt.remainingAmount,
      dueDate: widget.debt.dueDate,
      language: _selectedLanguage,
      isOverdue: widget.debt.isOverdue,
    );
  }

  Future<void> _handleSend() async {
    final rawPhone = _phoneController.text.trim();
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 9) {
      setState(() {
        _phoneError = 'Veuillez saisir un numéro valide (9 chiffres).';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isSubmitting = true;
    });

    try {
      final sanitizedPhone = _whatsAppService.sanitizePhoneNumber(rawPhone);
      final message = _buildPreviewMessage();

      // Mise à jour du numéro du débiteur en base si nécessaire
      final repo = _debtRepository;
      if (repo != null) {
        var debtor = widget.debt.debtor;
        if (debtor == null) {
          final debtorResult = await repo.getDebtorById(widget.debt.debtorId);
          debtor = debtorResult.fold(onSuccess: (d) => d, onError: (_) => null);
        }
        if (debtor != null && debtor.phoneNumber != sanitizedPhone) {
          final updatedDebtor = debtor.copyWith(phoneNumber: sanitizedPhone);
          await repo.updateDebtor(updatedDebtor);
        }
      }

      final success = await _whatsAppService.launchWhatsApp(
        phoneNumber: sanitizedPhone,
        message: message,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(success);

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('✓ Message de relance préparé dans WhatsApp.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            key: ValueKey('whatsapp_error_snackbar'),
            content: Text(
              'Impossible d\'ouvrir WhatsApp. Vérifiez que l\'application est bien installée.',
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('whatsapp_error_snackbar'),
          content: Text('Erreur lors de la préparation de la relance: $e'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final debtorName = (widget.debt.debtor?.name.trim().isNotEmpty == true)
        ? widget.debt.debtor!.name.trim()
        : 'Client';
    final remainingFormatted = CurrencyFormatter.format(
      widget.debt.remainingAmount,
    );
    final isLate = widget.debt.isOverdue;

    return Container(
      key: const ValueKey('whatsapp_reminder_bottom_sheet'),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Relance WhatsApp 1-Clic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$debtorName · Solde dû : $remainingFormatted',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.secondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone input field
            TextFormField(
              key: const ValueKey('whatsapp_phone_input'),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) {
                if (_phoneError != null) {
                  setState(() => _phoneError = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone WhatsApp',
                hintText: 'Ex: 77 123 45 67',
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.secondary,
                ),
                errorText: _phoneError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.tertiary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language switcher
            Row(
              children: [
                const Text(
                  'Langue du message :',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  key: const ValueKey('whatsapp_lang_wolof'),
                  label: const Text('Wolof'),
                  selected: _selectedLanguage == WhatsAppReminderLanguage.wolof,
                  selectedColor: AppColors.secondary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _selectedLanguage == WhatsAppReminderLanguage.wolof
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(
                        () =>
                            _selectedLanguage = WhatsAppReminderLanguage.wolof,
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const ValueKey('whatsapp_lang_french'),
                  label: const Text('Français'),
                  selected:
                      _selectedLanguage == WhatsAppReminderLanguage.french,
                  selectedColor: AppColors.secondary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _selectedLanguage == WhatsAppReminderLanguage.french
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(
                        () =>
                            _selectedLanguage = WhatsAppReminderLanguage.french,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Message preview card
            Container(
              key: const ValueKey('whatsapp_message_preview'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLate
                      ? AppColors.accent.withValues(alpha: 0.4)
                      : AppColors.tertiary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Aperçu du message',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      const Spacer(),
                      if (isLate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '⚠️ Retard',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _buildPreviewMessage(),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action button (touch target >= 48dp)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: ElevatedButton.icon(
                key: const ValueKey('whatsapp_send_button'),
                onPressed: _isSubmitting ? null : _handleSend,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Ouverture...' : 'Ouvrir WhatsApp',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
