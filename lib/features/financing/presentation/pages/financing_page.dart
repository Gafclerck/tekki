import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financing/data/repositories/financial_partner_repository_impl.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/repositories/loan_application_repository.dart';
import 'package:tekki/features/financing/domain/usecases/evaluate_loan_eligibility_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/get_financial_partners_use_case.dart';
import 'package:tekki/features/financing/domain/usecases/watch_loan_applications_use_case.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_cubit.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_state.dart';
import 'package:tekki/features/financing/presentation/widgets/borrowing_capacity_hero_card.dart';
import 'package:tekki/features/financing/presentation/widgets/loan_application_card.dart';
import 'package:tekki/features/financing/presentation/widgets/loan_request_sheet.dart';
import 'package:tekki/features/financing/presentation/widgets/partner_card.dart';
import 'package:tekki/injection_container.dart';

class FinancingPage extends StatefulWidget {
  const FinancingPage({
    super.key,
    this.cubit,
    this.shopId = 'default-shop',
    this.onNavigateToPassport,
  });

  final FinancingCubit? cubit;
  final String shopId;
  final VoidCallback? onNavigateToPassport;

  @override
  State<FinancingPage> createState() => _FinancingPageState();
}

class _FinancingPageState extends State<FinancingPage> {
  late final FinancingCubit _cubit;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
    } else if (sl.isRegistered<FinancingCubit>()) {
      _cubit = sl<FinancingCubit>();
    } else if (sl.isRegistered<GetFinancialPartnersUseCase>()) {
      _cubit = FinancingCubit(
        getFinancialPartnersUseCase: sl(),
        evaluateLoanEligibilityUseCase: sl(),
        watchLoanApplicationsUseCase: sl(),
        passportRepository: sl(),
      );
    } else {
      // Fallback sécurisé pour tests de widgets isolés sans DI
      _cubit = FinancingCubit(
        getFinancialPartnersUseCase: const GetFinancialPartnersUseCase(
          repository: FinancialPartnerRepositoryImpl(),
        ),
        evaluateLoanEligibilityUseCase: const EvaluateLoanEligibilityUseCase(),
        watchLoanApplicationsUseCase: WatchLoanApplicationsUseCase(
          repository: _FallbackLoanApplicationRepository(),
        ),
        passportRepository: _FallbackPassportRepository(),
      );
    }

    if (_cubit.state.status == FinancingStatus.initial) {
      _cubit.loadFinancingData(shopId: widget.shopId);
    }
  }

  @override
  void dispose() {
    if (widget.cubit == null) {
      _cubit.close();
    }
    super.dispose();
  }

  void _openLoanRequest({
    FinancialPartnerEntity? preselectedPartner,
    int? preselectedAmount,
  }) {
    final state = _cubit.state;
    LoanRequestSheet.show(
      context,
      partners: state.partners,
      currentScore: state.eligibility?.currentScore ?? 0,
      preselectedPartner: preselectedPartner,
      preselectedAmount:
          preselectedAmount ?? state.eligibility?.maxBorrowingCapacity,
      shopId: widget.shopId,
      onSubmitted: (_) {
        _cubit.refresh(shopId: widget.shopId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        key: const ValueKey('financing_page'),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<FinancingCubit, FinancingState>(
            builder: (context, state) {
              if (state.status == FinancingStatus.loading &&
                  state.partners.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    key: ValueKey('financing_loading_indicator'),
                    color: AppColors.primary,
                  ),
                );
              }

              if (state.status == FinancingStatus.error &&
                  state.partners.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage ??
                              'Erreur lors du chargement des financements.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _cubit.loadFinancingData(shopId: widget.shopId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.refresh(shopId: widget.shopId),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // En-tête de section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Financement Commercial',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  'Prêts Partenaires',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.accent,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Certifié D2D',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Carte Héroïque Capacité d'Emprunt
                      BorrowingCapacityHeroCard(
                        eligibility: state.eligibility,
                        onRequestLoan: () => _openLoanRequest(),
                        onViewPassport: widget.onNavigateToPassport,
                      ),
                      const SizedBox(height: 20),

                      // Section : Mes Demandes en cours
                      if (state.applications.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mes Demandes de Financement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${state.applications.length} active${state.applications.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...state.applications.map(
                          (app) => LoanApplicationCard(application: app),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Section : Catalogue des Partenaires
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Institutions Financières Partenaires',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Zone UEMOA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ...state.partners.map((partner) {
                        final isEligible =
                            state.eligibility?.eligiblePartnerIds.contains(
                              partner.id,
                            ) ??
                            false;
                        return PartnerCard(
                          partner: partner,
                          isEligible: isEligible,
                          onApply: () =>
                              _openLoanRequest(preselectedPartner: partner),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FallbackLoanApplicationRepository implements LoanApplicationRepository {
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

class _FallbackPassportRepository implements PassportRepository {
  @override
  Future<Result<FinancialPassportEntity, Failure>> getFinancialPassport({
    DateTime? asOf,
    int windowDays = 30,
  }) async => Result.success(
    FinancialPassportEntity(
      overallScore: 75,
      isEligible: true,
      totalClosures: 10,
      remainingClosures: 0,
      streak: 10,
      breakdown: ScoreBreakdownEntity(
        closureScore: 75,
        debtScore: 80,
        gpsScore: 100,
        cashScore: 90,
      ),
      calculatedAt: DateTime.now(),
    ),
  );
}
