import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/theme/app_theme.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';
import 'package:tekki/features/financing/domain/entities/loan_eligibility_entity.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_cubit.dart';
import 'package:tekki/features/financing/presentation/cubit/financing_state.dart';
import 'package:tekki/features/financing/presentation/pages/financing_page.dart';
import 'package:tekki/features/financing/presentation/widgets/borrowing_capacity_hero_card.dart';
import 'package:tekki/features/financing/presentation/widgets/loan_application_card.dart';
import 'package:tekki/features/financing/presentation/widgets/partner_card.dart';

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

void main() {
  late MockFinancingCubit mockCubit;

  const partners = FinancialPartnerCatalog.defaultPartners;
  const eligibility = LoanEligibilityEntity(
    isEligible: true,
    maxBorrowingCapacity: 1500000,
    currentScore: 82,
    closuresCount: 14,
    grade: 'A+',
    statusSummary: 'Éligible',
    eligiblePartnerIds: ['baobab_sn', 'cofina_sn', 'pamecas_sn', 'ecobank_sn'],
    recommendationMessage: 'Excellente solvabilité certifiée.',
  );

  final testApp = LoanApplicationEntity(
    id: 'demo-1',
    shopId: 'default-shop',
    partnerId: 'baobab_sn',
    partnerName: 'Baobab Sénégal',
    requestedAmount: 500000,
    durationMonths: 6,
    monthlyPaymentEstimate: 92500,
    purpose: LoanPurpose.stock,
    status: LoanStatus.underReview,
    submissionDate: DateTime.now(),
    passportScoreAtSubmission: 82,
  );

  setUp(() {
    mockCubit = MockFinancingCubit();
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: FinancingPage(cubit: mockCubit),
    );
  }

  group('FinancingPage Widget Tests', () {
    testWidgets('renders hero card, partner cards, and active applications', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        FinancingState(
          status: FinancingStatus.loaded,
          eligibility: eligibility,
          partners: partners,
          applications: [testApp],
        ),
      );

      await tester.pumpWidget(buildSubject());

      // Header
      expect(find.text('Financement Commercial'), findsOneWidget);
      expect(find.text('Prêts Partenaires'), findsOneWidget);

      // Hero Card
      expect(find.byType(BorrowingCapacityHeroCard), findsOneWidget);
      expect(find.text('Capacité d\'emprunt certifiée Tekki'), findsOneWidget);
      expect(find.text('1 500 000 FCFA'), findsOneWidget);
      expect(find.text('Demander un prêt'), findsOneWidget);

      // Partner Cards
      expect(find.byType(PartnerCard), findsNWidgets(4));
      expect(find.text('Baobab Sénégal'), findsWidgets);
      expect(find.text('COFINA Sénégal'), findsOneWidget);
      expect(find.text('PAMECAS'), findsOneWidget);
      expect(find.text('Ecobank Micro-Business'), findsOneWidget);

      // Loan Application Card
      expect(find.byType(LoanApplicationCard), findsOneWidget);
      expect(find.text('En cours d\'étude'), findsOneWidget);
    });

    testWidgets('renders loading spinner when loading with empty partners', (
      tester,
    ) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const FinancingState(status: FinancingStatus.loading));

      await tester.pumpWidget(buildSubject());

      expect(
        find.byKey(const ValueKey('financing_loading_indicator')),
        findsOneWidget,
      );
    });
  });
}
