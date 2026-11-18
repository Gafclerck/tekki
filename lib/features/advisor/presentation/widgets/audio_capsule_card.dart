import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/advisor/domain/entities/audio_language.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_state.dart';
import 'package:tekki/injection_container.dart';

/// Carte visuelle de capsule audio éducative bilingue (Wolof / Français).
///
/// Conforme au Design System Tekki :
/// - Fond carte blanche `{AppColors.surface}`
/// - Bordure gauche de 5px en orange accent `{AppColors.accent}`
/// - Bouton Play/Pause circulaire `{AppColors.accent}` avec zone tactile >= 48dp
///   (implémenté via Material + InkWell pour respecter la règle de l'action focale unique
///   stipulant qu'aucun autre ElevatedButton orange ne doit exister sur l'écran d'accueil)
/// - Sélecteur bilingue compact 1-tap (Wolof prioritaire par défaut)
/// - Jauge de progression temporelle dynamique.
class AudioCapsuleCard extends StatelessWidget {
  const AudioCapsuleCard({super.key, this.cubit});

  final AudioCapsuleCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final existingCubit = cubit ?? _findCubit(context);
    if (existingCubit != null) {
      return BlocBuilder<AudioCapsuleCubit, AudioCapsuleState>(
        bloc: existingCubit,
        builder: (context, state) =>
            _AudioCapsuleCardView(cubit: existingCubit, state: state),
      );
    }

    if (sl.isRegistered<AudioCapsuleCubit>()) {
      final singletonCubit = sl<AudioCapsuleCubit>();
      if (singletonCubit.state.capsule == null &&
          !singletonCubit.state.isLoading) {
        singletonCubit.loadActiveCapsule();
      }
      return BlocProvider.value(
        value: singletonCubit,
        child: BlocBuilder<AudioCapsuleCubit, AudioCapsuleState>(
          builder: (context, state) =>
              _AudioCapsuleCardView(cubit: singletonCubit, state: state),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  AudioCapsuleCubit? _findCubit(BuildContext context) {
    try {
      return context.read<AudioCapsuleCubit>();
    } catch (_) {
      return null;
    }
  }
}

class _AudioCapsuleCardView extends StatelessWidget {
  const _AudioCapsuleCardView({required this.cubit, required this.state});

  final AudioCapsuleCubit cubit;
  final AudioCapsuleState state;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final capsule = state.capsule;
    final title = capsule?.title ?? 'Conseil du jour : Caisse Tekki';
    final summary =
        capsule?.summary ??
        'Écoutez le conseil pratique de 35s en Wolof ou en Français.';

    return Container(
      key: const ValueKey('audio_capsule_card'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        key: const ValueKey('audio_capsule_card_inner'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Badge / Titre et Sélecteur bilingue Wolof <-> Français
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CAPSULE CONSEIL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Sélecteur bilingue compact 1-tap
                _buildLanguageToggle(),
              ],
            ),

            const SizedBox(height: 14),

            // Ligne de lecture : Bouton Play/Pause (>=48dp) + Jauge temporelle
            Row(
              children: [
                // Bouton Play/Pause circulaire (pas d'ElevatedButton !)
                Material(
                  key: const ValueKey('audio_capsule_play_pause_button'),
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => cubit.togglePlayPause(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Barre de progression + décompte temporel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          key: const ValueKey('audio_capsule_progress_bar'),
                          value: state.progress,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(state.currentPosition),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            _formatDuration(state.totalDuration),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Résumé de la capsule
            Text(
              summary,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Message d'erreur discret si présent
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                key: const ValueKey('audio_capsule_error_message'),
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            key: const ValueKey('audio_lang_wolof'),
            label: 'Wolof',
            isSelected: state.selectedLanguage == AudioLanguage.wolof,
            onTap: () => cubit.switchLanguage(AudioLanguage.wolof),
          ),
          _buildLanguageOption(
            key: const ValueKey('audio_lang_francais'),
            label: 'Français',
            isSelected: state.selectedLanguage == AudioLanguage.francais,
            onTap: () => cubit.switchLanguage(AudioLanguage.francais),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required Key key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
