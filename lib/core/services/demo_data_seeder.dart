import 'package:drift/drift.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class DemoDataSeederService {
  const DemoDataSeederService({
    required AppDatabase database,
    ICryptoSignatureService? cryptoSignatureService,
  }) : _db = database,
       _crypto = cryptoSignatureService;

  final AppDatabase _db;
  final ICryptoSignatureService? _crypto;
  static const Uuid _uuid = Uuid();

  static const String defaultShopId = 'default-shop';

  /// Injects complete realistic demo data covering all use cases:
  /// - 14 consecutive daily closures (unlocks full Financial Passport & High Score)
  /// - 30+ sales with CASH, WAVE, and ORANGE_MONEY
  /// - 4 debtors with active, overdue, and paid debts in Karné Bor
  /// - 2 loan applications with partner institutions (under review & approved)
  Future<void> seedCompleteTestData() async {
    // 0. Ensure cryptographic key pair exists for the merchant
    if (_crypto != null) {
      await _crypto.getOrCreatePublicKey(shopId: defaultShopId);
    }

    final now = DateTime.now();

    // 1. Ensure Shop exists
    await _db
        .into(_db.shops)
        .insert(
          ShopsCompanion(
            id: const Value(defaultShopId),
            name: const Value('Boutique Keur Serigne Bi'),
            refLatitude: const Value(14.6928),
            refLongitude: const Value(-17.4467),
            publicKey: const Value('ed25519-demo-public-key-tekki'),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 30)).toIso8601String(),
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );

    // 2. Clear existing dynamic tables to guarantee clean state
    await clearAllData(keepShop: true);

    // 3. Generate 14 days of consecutive daily closures
    // Giving a 14-day streak, high recovery rate, strong certified turnover
    final closureAmounts = [
      42000,
      55000,
      38000,
      67000,
      51000,
      49000,
      72000,
      60000,
      58000,
      84000,
      63000,
      77000,
      91000,
      65000,
    ];

    for (int i = 14; i >= 1; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final totalSales = closureAmounts[14 - i];

      await _db
          .into(_db.dailyClosures)
          .insert(
            DailyClosuresCompanion(
              id: Value('closure-$dateStr'),
              shopId: const Value(defaultShopId),
              closureDate: Value(dateStr),
              cutoffTimestamp: Value(date.toIso8601String()),
              totalSalesAmount: Value(totalSales),
              totalCashDebtInflow: const Value(10000),
              totalCreditSalesAmount: const Value(5000),
              totalExpensesAmount: const Value(5000),
              cashCounted: Value(totalSales + 5000),
              isFlaggedLocation: const Value(false),
              syncStatus: const Value('synced'),
              createdAt: Value(date.toIso8601String()),
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Historical sales associated to this day
      final sale1 = (totalSales * 0.6).round();
      final sale2 = totalSales - sale1;

      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion(
              id: Value('sale-hist-$i-1'),
              amount: Value(sale1),
              paymentMethod: const Value('CASH'),
              recordedAt: Value(
                date.add(const Duration(hours: 10)).toIso8601String(),
              ),
              closureId: Value('closure-$dateStr'),
              syncStatus: const Value('synced'),
            ),
          );
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion(
              id: Value('sale-hist-$i-2'),
              amount: Value(sale2),
              paymentMethod: const Value('WAVE'),
              recordedAt: Value(
                date.add(const Duration(hours: 15)).toIso8601String(),
              ),
              closureId: Value('closure-$dateStr'),
              syncStatus: const Value('synced'),
            ),
          );
    }

    // 4. Insert Today's unclosed sales
    final todaySales = [
      (15000, 'CASH'),
      (25000, 'WAVE'),
      (12000, 'ORANGE_MONEY'),
      (8000, 'CASH'),
    ];

    for (var j = 0; j < todaySales.length; j++) {
      final (amount, method) = todaySales[j];
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion(
              id: Value('sale-today-$j'),
              amount: Value(amount),
              paymentMethod: Value(method),
              recordedAt: Value(
                now.subtract(Duration(hours: 4 - j)).toIso8601String(),
              ),
              closureId: const Value(null),
              syncStatus: const Value('pending'),
            ),
          );
    }

    // 5. Insert Debtors & Debts (Karné Bor)
    final debtor1Id = _uuid.v4();
    final debtor2Id = _uuid.v4();
    final debtor3Id = _uuid.v4();
    final debtor4Id = _uuid.v4();

    await _db
        .into(_db.debtors)
        .insert(
          DebtorsCompanion(
            id: Value(debtor1Id),
            name: const Value('Moussa Diop'),
            phoneNumber: const Value('+221 77 234 56 78'),
            createdAt: Value(
              now.subtract(const Duration(days: 20)).toIso8601String(),
            ),
          ),
        );
    await _db
        .into(_db.debtors)
        .insert(
          DebtorsCompanion(
            id: Value(debtor2Id),
            name: const Value('Awa Ndiaye'),
            phoneNumber: const Value('+221 78 345 67 89'),
            createdAt: Value(
              now.subtract(const Duration(days: 15)).toIso8601String(),
            ),
          ),
        );
    await _db
        .into(_db.debtors)
        .insert(
          DebtorsCompanion(
            id: Value(debtor3Id),
            name: const Value('Ibrahima Diallo'),
            phoneNumber: const Value('+221 76 456 78 90'),
            createdAt: Value(
              now.subtract(const Duration(days: 30)).toIso8601String(),
            ),
          ),
        );
    await _db
        .into(_db.debtors)
        .insert(
          DebtorsCompanion(
            id: Value(debtor4Id),
            name: const Value('Fatou Ba'),
            phoneNumber: const Value('+221 70 567 89 01'),
            createdAt: Value(
              now.subtract(const Duration(days: 25)).toIso8601String(),
            ),
          ),
        );

    // Debt 1: Moussa Diop (Partially paid, remaining 20 000 FCFA, active)
    final debt1Id = _uuid.v4();
    await _db
        .into(_db.debts)
        .insert(
          DebtsCompanion(
            id: Value(debt1Id),
            debtorId: Value(debtor1Id),
            initialAmount: const Value(35000),
            remainingAmount: const Value(20000),
            dueDate: Value(now.add(const Duration(days: 5)).toIso8601String()),
            status: const Value('ACTIVE'),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 8)).toIso8601String(),
            ),
          ),
        );
    await _db
        .into(_db.debtPayments)
        .insert(
          DebtPaymentsCompanion(
            id: Value(_uuid.v4()),
            debtId: Value(debt1Id),
            paymentAmount: const Value(15000),
            paymentMethod: const Value('WAVE'),
            syncStatus: const Value('synced'),
            paidAt: Value(
              now.subtract(const Duration(days: 3)).toIso8601String(),
            ),
          ),
        );

    // Debt 2: Awa Ndiaye (15 000 FCFA, on schedule)
    await _db
        .into(_db.debts)
        .insert(
          DebtsCompanion(
            id: Value(_uuid.v4()),
            debtorId: Value(debtor2Id),
            initialAmount: const Value(15000),
            remainingAmount: const Value(15000),
            dueDate: Value(now.add(const Duration(days: 7)).toIso8601String()),
            status: const Value('ACTIVE'),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 2)).toIso8601String(),
            ),
          ),
        );

    // Debt 3: Ibrahima Diallo (45 000 FCFA, OVERDUE by 10 days!)
    await _db
        .into(_db.debts)
        .insert(
          DebtsCompanion(
            id: Value(_uuid.v4()),
            debtorId: Value(debtor3Id),
            initialAmount: const Value(45000),
            remainingAmount: const Value(45000),
            dueDate: Value(
              now.subtract(const Duration(days: 10)).toIso8601String(),
            ),
            status: const Value('ACTIVE'),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 25)).toIso8601String(),
            ),
          ),
        );

    // Debt 4: Fatou Ba (Settled)
    final debt4Id = _uuid.v4();
    await _db
        .into(_db.debts)
        .insert(
          DebtsCompanion(
            id: Value(debt4Id),
            debtorId: Value(debtor4Id),
            initialAmount: const Value(25000),
            remainingAmount: const Value(0),
            dueDate: Value(
              now.subtract(const Duration(days: 5)).toIso8601String(),
            ),
            status: const Value('PAID'),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 18)).toIso8601String(),
            ),
          ),
        );
    await _db
        .into(_db.debtPayments)
        .insert(
          DebtPaymentsCompanion(
            id: Value(_uuid.v4()),
            debtId: Value(debt4Id),
            paymentAmount: const Value(25000),
            paymentMethod: const Value('CASH'),
            syncStatus: const Value('synced'),
            paidAt: Value(
              now.subtract(const Duration(days: 6)).toIso8601String(),
            ),
          ),
        );

    // 6. Insert Demo Loan Applications
    await _db
        .into(_db.loanApplications)
        .insert(
          LoanApplicationsCompanion(
            id: const Value('demo-app-1'),
            shopId: const Value(defaultShopId),
            partnerId: const Value('baobab_sn'),
            partnerName: const Value('Baobab Sénégal'),
            requestedAmount: const Value(500000),
            durationMonths: const Value(6),
            monthlyPaymentEstimate: const Value(92500),
            purpose: const Value('stock'),
            status: const Value('UNDER_REVIEW'),
            passportScoreAtSubmission: const Value(82),
            submissionDate: Value(
              now.subtract(const Duration(days: 2)).toIso8601String(),
            ),
            decisionNotes: const Value(
              'Dossier en cours d\'analyse financière.',
            ),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 2)).toIso8601String(),
            ),
          ),
        );

    await _db
        .into(_db.loanApplications)
        .insert(
          LoanApplicationsCompanion(
            id: const Value('demo-app-2'),
            shopId: const Value(defaultShopId),
            partnerId: const Value('cofina_sn'),
            partnerName: const Value('COFINA Sénégal'),
            requestedAmount: const Value(1200000),
            durationMonths: const Value(12),
            monthlyPaymentEstimate: const Value(118000),
            purpose: const Value('expansion'),
            status: const Value('APPROVED'),
            passportScoreAtSubmission: const Value(84),
            submissionDate: Value(
              now.subtract(const Duration(days: 5)).toIso8601String(),
            ),
            decisionNotes: const Value(
              'Approbation confirmée. Prêt pour décaissement.',
            ),
            syncStatus: const Value('synced'),
            createdAt: Value(
              now.subtract(const Duration(days: 5)).toIso8601String(),
            ),
          ),
        );
  }

  /// Clears all dynamic database tables for fresh empty-state testing
  Future<void> clearAllData({bool keepShop = false}) async {
    await _db.delete(_db.loanApplications).go();
    await _db.delete(_db.debtPayments).go();
    await _db.delete(_db.debts).go();
    await _db.delete(_db.debtors).go();
    await _db.delete(_db.sales).go();
    await _db.delete(_db.dailyClosures).go();
    await _db.delete(_db.syncOutbox).go();
    if (!keepShop) {
      await _db.delete(_db.shops).go();
    }
  }
}
