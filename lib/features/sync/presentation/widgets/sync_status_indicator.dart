import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_state.dart';
import 'package:tekki/injection_container.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key, this.cubit, this.compact = true});

  final SyncCubit? cubit;
  final bool compact;

  SyncCubit? _findCubit(BuildContext context) {
    try {
      return context.read<SyncCubit>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit ?? _findCubit(context);
    if (activeCubit != null) {
      return BlocBuilder<SyncCubit, SyncState>(
        bloc: activeCubit,
        builder: (context, state) =>
            _SyncStatusIndicatorView(cubit: activeCubit, state: state),
      );
    }

    if (sl.isRegistered<SyncCubit>()) {
      final singletonCubit = sl<SyncCubit>();
      return BlocProvider.value(
        value: singletonCubit,
        child: BlocBuilder<SyncCubit, SyncState>(
          builder: (context, state) =>
              _SyncStatusIndicatorView(cubit: singletonCubit, state: state),
        ),
      );
    }

    // Graceful static fallback when no SyncCubit is registered
    return _buildStaticFallback();
  }

  Widget _buildStaticFallback() {
    return Container(
      key: const ValueKey('sync_status_indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tertiary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '100% Hors-ligne',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusIndicatorView extends StatelessWidget {
  const _SyncStatusIndicatorView({required this.cubit, required this.state});

  final SyncCubit cubit;
  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String labelText;
    final Widget statusIcon;

    if (state.isSyncing) {
      statusColor = AppColors.accent;
      labelText = 'Synchronisation...';
      statusIcon = const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    } else if (state.pendingCount > 0) {
      statusColor = const Color(0xFFE57A00); // Amber
      labelText = state.isOnline
          ? '${state.pendingCount} en attente'
          : 'Hors-ligne (${state.pendingCount})';
      statusIcon = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
      );
    } else if (state.failedCount > 0) {
      statusColor = AppColors.error;
      labelText = 'Échec de synchronisation';
      statusIcon = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
      );
    } else {
      statusColor = AppColors.success;
      labelText = state.isOnline ? 'Synchronisé' : '100% Hors-ligne';
      statusIcon = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
      );
    }

    return InkWell(
      key: const ValueKey('sync_status_indicator'),
      onTap: () {
        cubit.syncNow();
        final message = state.isSyncing
            ? 'Synchronisation en cours...'
            : state.pendingCount > 0
            ? '${state.pendingCount} transaction(s) en attente de synchronisation'
            : 'Toutes les données sont sécurisées et synchronisées';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const ValueKey('sync_status_snackbar'),
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.tertiary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            statusIcon,
            const SizedBox(width: 6),
            Text(
              labelText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
