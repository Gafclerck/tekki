import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/services/brightness_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_encouragement_view.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_qr_card.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_score_badge_card.dart';
import 'package:tekki/injection_container.dart';

class PassportOverviewPage extends StatefulWidget {
  const PassportOverviewPage({
    super.key,
    this.brightnessService,
    this.bloc,
    this.shopId = 'default-shop',
    this.enablePeriodicTicker = true,
    this.showBackButton = true,
  });

  final IBrightnessService? brightnessService;
  final PassportBloc? bloc;
  final String shopId;
  final bool enablePeriodicTicker;
  final bool showBackButton;

  @override
  State<PassportOverviewPage> createState() => _PassportOverviewPageState();
}

class _PassportOverviewPageState extends State<PassportOverviewPage> {
  late final IBrightnessService _brightnessService;
  PassportBloc? _localBloc;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _brightnessService =
        widget.brightnessService ??
        (sl.isRegistered<IBrightnessService>()
            ? sl<IBrightnessService>()
            : ScreenBrightnessService());

    // Boost temporaire de luminosité au maximum pour optimiser le scan optique tiers
    _brightnessService.setMaxBrightness();

    // Démarrage du ticker 1 seconde pour rafraîchir le compte à rebours et renouveler le PIN à chaque minute
    if (widget.enablePeriodicTicker) {
      _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final bloc = widget.bloc ?? _localBloc ?? context.read<PassportBloc>();
        bloc.add(RefreshPinTickEvent(shopId: widget.shopId));
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.bloc == null && _localBloc == null) {
      final bloc = context.read<PassportBloc>();
      if (bloc.state is PassportInitial) {
        bloc.add(LoadPassportEvent(shopId: widget.shopId));
      }
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    // Restauration de la luminosité initiale lors de la fermeture ou du masquage
    _brightnessService.restoreBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc != null) {
      return BlocProvider.value(
        value: widget.bloc!,
        child: _buildScaffold(context),
      );
    }
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      key: const ValueKey('passport_overview_page'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
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
            const Text(
              'Mon Passeport',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                key: const ValueKey('passport_back_button'),
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiary, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.secondary,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'D2D Sécurisé',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<PassportBloc, PassportState>(
          listener: (context, state) {
            if (state is PassportActiveLoaded) {
              if (state.sharePdfError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    key: const ValueKey('passport_share_error_snackbar'),
                    content: Text(state.sharePdfError!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state.pdfSharedSuccessfully) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    key: ValueKey('passport_share_success_snackbar'),
                    content: Text(
                      'Attestation PDF générée et partagée avec succès !',
                    ),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is PassportLoading || state is PassportInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  key: ValueKey('passport_loading_indicator'),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is PassportError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        key: const ValueKey('passport_error_message'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        key: const ValueKey('passport_retry_button'),
                        onPressed: () {
                          context.read<PassportBloc>().add(
                            LoadPassportEvent(shopId: widget.shopId),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is PassportEncouragementLoaded) {
              return SingleChildScrollView(
                child: PassportEncouragementView(
                  passport: state.passport,
                  closuresNeeded: state.closuresNeeded,
                ),
              );
            }

            if (state is PassportActiveLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PassportScoreBadgeCard(passport: state.passport),
                    const SizedBox(height: 16),
                    PassportQrCard(
                      base45Payload: state.signedPayload.base45Payload,
                      visualPin: state.signedPayload.visualPin,
                      secondsRemaining: state.secondsRemainingInMinute,
                    ),
                    const SizedBox(height: 16),
                    // Action de partage de l'attestation PDF
                    ElevatedButton.icon(
                      key: const ValueKey('share_pdf_whatsapp_button'),
                      onPressed: state.isSharingPdf
                          ? null
                          : () {
                              final bloc =
                                  widget.bloc ??
                                  _localBloc ??
                                  context.read<PassportBloc>();
                              bloc.add(
                                SharePassportPdfEvent(shopName: widget.shopId),
                              );
                            },
                      icon: state.isSharingPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                key: ValueKey('share_pdf_loading_spinner'),
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                            ),
                      label: Text(
                        state.isSharingPdf
                            ? 'Génération de l\'attestation...'
                            : '📲 Partager l\'Attestation PDF sur WhatsApp',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: AppColors.accent.withAlpha(
                          180,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
