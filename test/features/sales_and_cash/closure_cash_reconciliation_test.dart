import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';

void main() {
  late AppDatabase db;
  late ClosureLocalDataSource closureDataSource;
  late DebtLocalDataSource debtDataSource;
  late SalesLocalDataSource salesDataSource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    closureDataSource = ClosureLocalDataSourceImpl(database: db);
    debtDataSource = DebtLocalDataSourceImpl(database: db);
    salesDataSource = SalesLocalDataSourceImpl(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Closure Cash Reconciliation with Debt Inflows', () {
    test(
      'sums unclosed cash debt payments before cutoff and seals them on closure',
      () async {
        // 1. Setup debtor and debt
        final debtor = DebtorEntity(
          id: 'debtor-1',
          name: 'Moussa Ndiaye',
          createdAt: DateTime.utc(2026, 11, 10),
        );
        final debt = DebtEntity(
          id: 'debt-1',
          debtorId: 'debtor-1',
          initialAmount: 20000,
          remainingAmount: 20000,
          dueDate: DateTime.utc(2026, 12, 1),
          createdAt: DateTime.utc(2026, 11, 10),
        );
        await debtDataSource.recordDebtWithDebtor(debtor: debtor, debt: debt);

        // 2. Insert cash payment of 5000 FCFA at 10:00 UTC
        final paymentTime = DateTime.utc(2026, 11, 17, 10, 0);
        final payment = DebtPaymentEntity(
          id: 'payment-1',
          debtId: 'debt-1',
          paymentAmount: 5000,
          paymentMethod: 'ESPECES',
          paidAt: paymentTime,
        );
        await debtDataSource.recordDebtPayment(
          payment: payment,
          updatedDebt: debt.copyWith(remainingAmount: 15000),
        );

        // Also insert a mobile money payment (should not count as cash inflow)
        final momoPayment = DebtPaymentEntity(
          id: 'payment-momo',
          debtId: 'debt-1',
          paymentAmount: 3000,
          paymentMethod: 'MOBILE_MONEY',
          paidAt: paymentTime,
        );
        await debtDataSource.recordDebtPayment(
          payment: momoPayment,
          updatedDebt: debt.copyWith(remainingAmount: 12000),
        );

        // 3. Insert a cash sale of 10000 FCFA
        final sale = SaleEntity(
          id: 'sale-1',
          amount: 10000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: paymentTime,
        );
        await salesDataSource.insertSale(sale);

        // 4. Check prefill at cutoff 12:00 UTC
        final cutoff = DateTime.utc(2026, 11, 17, 12, 0);
        final prefillSales = await closureDataSource.getPrefillSalesAmount(
          cutoff,
        );
        final prefillDebtCash = await closureDataSource
            .getPrefillDebtCashInflow(cutoff);

        expect(prefillSales, 10000);
        expect(prefillDebtCash, 5000);

        // Theoretical cash check
        final closure = DailyClosureEntity(
          id: 'closure-1',
          shopId: 'default-shop',
          closureDate: '2026-11-17',
          cutoffTimestamp: cutoff,
          totalSalesAmount: prefillSales,
          totalCashDebtInflow: prefillDebtCash,
          totalExpensesAmount: 2000,
          cashCounted: 13000,
        );

        expect(closure.theoreticalCash, 10000 + 5000 - 2000); // 13 000 FCFA
        expect(closure.difference, 0);

        // 5. Execute closure
        await closureDataSource.executeDailyClosure(closure);

        // 6. Verify payments are sealed with closureId
        final payments = await debtDataSource.getPaymentsByDebt('debt-1');
        final sealedCashPayment = payments.firstWhere(
          (p) => p.id == 'payment-1',
        );
        expect(sealedCashPayment.closureId, 'closure-1');

        // Subsequent prefill after closure should be 0
        final subsequentInflow = await closureDataSource
            .getPrefillDebtCashInflow(cutoff);
        expect(subsequentInflow, 0);
      },
    );
  });
}
