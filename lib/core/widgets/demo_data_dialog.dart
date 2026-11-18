import 'package:flutter/material.dart';
import 'package:tekki/core/services/demo_data_seeder.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/injection_container.dart';

class DemoDataDialog extends StatefulWidget {
  const DemoDataDialog({super.key, this.seederService, this.onDataChanged});

  final DemoDataSeederService? seederService;
  final VoidCallback? onDataChanged;

  static Future<void> show(
    BuildContext context, {
    DemoDataSeederService? seederService,
    VoidCallback? onDataChanged,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DemoDataDialog(
        seederService: seederService,
        onDataChanged: onDataChanged,
      ),
    );
  }

  @override
  State<DemoDataDialog> createState() => _DemoDataDialogState();
}

class _DemoDataDialogState extends State<DemoDataDialog> {
  bool _isLoading = false;
  String? _statusMessage;

  DemoDataSeederService get _seeder =>
      widget.seederService ?? sl<DemoDataSeederService>();

  Future<void> _seedData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Génération des données complètes...';
    });

    try {
      await _seeder.seedCompleteTestData();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDataChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: ValueKey('demo_data_seeded_snackbar'),
          content: Text(
            '✓ Données de test injectées : 14 clôtures, ventes, dettes & crédits prêts !',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erreur : $e';
      });
    }
  }

  Future<void> _clearData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Réinitialisation de la base...';
    });

    try {
      await _seeder.clearAllData();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDataChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: ValueKey('demo_data_cleared_snackbar'),
          content: Text(
            '✓ Base de données réinitialisée à zéro (état vierge).',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('demo_data_dialog'),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/branding/logo_symbol.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Données de Test & Démo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Testez immédiatement tous les use cases de l\'application (crédit bancaire, passeport actif, carnet de dettes, ventes journalières).',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading) ...[
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage ?? 'Opération en cours...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            ElevatedButton.icon(
              key: const ValueKey('seed_full_data_button'),
              onPressed: _seedData,
              icon: const Icon(Icons.auto_fix_high_rounded, size: 20),
              label: const Text(
                '🌱 Injecter le jeu de test complet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('clear_all_data_button'),
              onPressed: _clearData,
              icon: const Icon(
                Icons.delete_sweep_outlined,
                size: 20,
                color: AppColors.error,
              ),
              label: const Text(
                '🧹 Réinitialiser à zéro (Tester l\'état vierge)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
