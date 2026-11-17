import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

void main() {
  late AppDatabase database;
  late DebtLocalDataSourceImpl dataSource;

  final testDate = DateTime.utc(2026, 11, 17, 10, 0);

  setUp(() async {
    database = AppDatabase.forTesting(openConnection(inMemory: true));
    dataSource = DebtLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DebtLocalDataSourceImpl - Drift Integration & Transactions', () {
    test('inserts and retrieves debtor by id and name', () async {
      final debtor = DebtorEntity(
        id: 'debtor-1',
        name: 'Fatou Kiné',
        phoneNumber: '+221771234567',
        syncStatus: 'pending',
        createdAt: testDate,
      );

      await dataSource.insertDebtor(debtor);

      final retrieved = await dataSource.getDebtorById('debtor-1');
      expect(retrieved, isNotNull);
      expect(retrieved?.id, 'debtor-1');
      expect(retrieved?.name, 'Fatou Kiné');
      expect(retrieved?.phoneNumber, '+221771234567');

      // Case-insensitive search
      final found = await dataSource.findDebtorByName('  fatou kiné  ');
      expect(found, isNotNull);
      expect(found?.id, 'debtor-1');
    });

    test('searches debtors with case-insensitivity and limit', () async {
      await dataSource.insertDebtor(
        DebtorEntity(id: 'd-1', name: 'Modou Fall', createdAt: testDate),
      );
      await dataSource.insertDebtor(
        DebtorEntity(id: 'd-2', name: 'Modou Ndiaye', createdAt: testDate),
      );
      await dataSource.insertDebtor(
        DebtorEntity(id: 'd-3', name: 'Awa Diop', createdAt: testDate),
      );

      final results = await dataSource.searchDebtors('modou');
      expect(results.length, 2);
      expect(
        results.map((d) => d.name).toList(),
        containsAll(['Modou Fall', 'Modou Ndiaye']),
      );
    });

    test(
      'watchActiveDebts emits active and overdue debts ordered by due_date, excluding settled',
      () async {
        final debtor = DebtorEntity(
          id: 'stream-debtor-1',
          name: 'Stream Client',
          createdAt: testDate,
        );
        await dataSource.insertDebtor(debtor);

        final debtSoon = DebtEntity(
          id: 'stream-debt-soon',
          debtorId: 'stream-debtor-1',
          initialAmount: 2000,
          remainingAmount: 2000,
          dueDate: testDate.add(const Duration(days: 2)),
          status: DebtStatus.active,
          createdAt: testDate,
        );
        final debtOverdue = DebtEntity(
          id: 'stream-debt-overdue',
          debtorId: 'stream-debtor-1',
          initialAmount: 4000,
          remainingAmount: 4000,
          dueDate: testDate.subtract(const Duration(days: 3)),
          status: DebtStatus.overdue,
          createdAt: testDate,
        );
        final debtSettled = DebtEntity(
          id: 'stream-debt-settled',
          debtorId: 'stream-debtor-1',
          initialAmount: 5000,
          remainingAmount: 0,
          dueDate: testDate.subtract(const Duration(days: 1)),
          status: DebtStatus.settled,
          createdAt: testDate,
        );

        final expectation = expectLater(
          dataSource.watchActiveDebts(),
          emitsInOrder([
            isEmpty,
            // After inserting debtOverdue
            predicate<List<DebtEntity>>(
              (l) => l.length == 1 && l.first.id == 'stream-debt-overdue',
            ),
            // After inserting debtSettled: still only debtOverdue, length remains 1
            predicate<List<DebtEntity>>(
              (l) => l.length == 1 && l.first.id == 'stream-debt-overdue',
            ),
            // After inserting debtSoon: both debtOverdue and debtSoon, excluding debtSettled
            predicate<List<DebtEntity>>(
              (l) =>
                  l.length == 2 && !l.any((d) => d.id == 'stream-debt-settled'),
            ),
          ]),
        );

        // Allow stream setup
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await dataSource.insertDebt(debtOverdue);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await dataSource.insertDebt(debtSettled);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await dataSource.insertDebt(debtSoon);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await expectation;

        // getActiveDebts also includes active and overdue, excluding settled
        final activeDebts = await dataSource.getActiveDebts();
        expect(activeDebts.length, 2);
        expect(activeDebts.map((d) => d.id).toList(), [
          'stream-debt-overdue',
          'stream-debt-soon',
        ]);
      },
    );

    test(
      'records debt payment atomically, reduces remainingAmount and transitions to SETTLED when 0',
      () async {
        final debtor = DebtorEntity(
          id: 'pay-debtor-1',
          name: 'Samba Diouf',
          createdAt: testDate,
        );
        final debt = DebtEntity(
          id: 'pay-debt-1',
          debtorId: 'pay-debtor-1',
          initialAmount: 10000,
          remainingAmount: 10000,
          dueDate: testDate.add(const Duration(days: 7)),
          status: DebtStatus.active,
          createdAt: testDate,
        );

        await dataSource.recordDebtWithDebtor(debtor: debtor, debt: debt);

        // 1. Partial payment: 4 000 FCFA
        final payment1 = DebtPaymentEntity(
          id: 'payment-uuid-1',
          debtId: 'pay-debt-1',
          paymentAmount: 4000,
          paymentMethod: 'ESPECES',
          paidAt: testDate.add(const Duration(hours: 1)),
        );

        await dataSource.recordDebtPayment(
          payment: payment1,
          updatedDebt: debt.copyWith(remainingAmount: 6000),
        );

        final debtAfterPay1 = await dataSource.getDebtById('pay-debt-1');
        expect(debtAfterPay1?.remainingAmount, 6000);
        expect(debtAfterPay1?.status, DebtStatus.active);

        // 2. Full remaining payment: 6 000 FCFA -> SETTLED
        final payment2 = DebtPaymentEntity(
          id: 'payment-uuid-2',
          debtId: 'pay-debt-1',
          paymentAmount: 6000,
          paymentMethod: 'ESPECES',
          paidAt: testDate.add(const Duration(hours: 2)),
        );

        await dataSource.recordDebtPayment(
          payment: payment2,
          updatedDebt: debt.copyWith(
            remainingAmount: 0,
            status: DebtStatus.settled,
          ),
        );

        final debtAfterPay2 = await dataSource.getDebtById('pay-debt-1');
        expect(debtAfterPay2?.remainingAmount, 0);
        expect(debtAfterPay2?.status, DebtStatus.settled);

        // 3. Query payments history
        final payments = await dataSource.getPaymentsByDebt('pay-debt-1');
        expect(payments.length, 2);
        expect(payments[0].id, 'payment-uuid-2'); // ordered by paidAt desc
        expect(payments[1].id, 'payment-uuid-1');
        expect(payments[0].paymentAmount, 6000);
        expect(payments[1].paymentAmount, 4000);
      },
    );

    test('updateDebtor updates phone number and persists in SQLite', () async {
      final debtor = DebtorEntity(
        id: 'debtor-upd',
        name: 'Samba Diop',
        phoneNumber: null,
        createdAt: testDate,
      );
      await dataSource.insertDebtor(debtor);

      final updated = debtor.copyWith(phoneNumber: '221771234567');
      await dataSource.updateDebtor(updated);

      final reloaded = await dataSource.getDebtorById('debtor-upd');
      expect(reloaded?.phoneNumber, '221771234567');
    });

    test(
      'getRecoveryVelocity aggregates debts and payments in 30-day window',
      () async {
        // 1. Carnet vierge
        final emptyVelocity = await dataSource.getRecoveryVelocity(
          asOf: testDate,
        );
        expect(emptyVelocity.rate, 100);
        expect(emptyVelocity.totalDueAmount, 0);
        expect(emptyVelocity.totalRecoveredAmount, 0);

        // 2. Debts and payments:
        // Debtor
        final debtor = DebtorEntity(
          id: 'debtor-v',
          name: 'Velocity Client',
          createdAt: testDate,
        );
        await dataSource.insertDebtor(debtor);

        // Debt 1: 50 000 F, paid 50 000 F on time -> settled
        final debt1 = DebtEntity(
          id: 'debt-v1',
          debtorId: 'debtor-v',
          initialAmount: 50000,
          remainingAmount: 0,
          dueDate: testDate.subtract(const Duration(days: 5)),
          status: DebtStatus.settled,
          createdAt: testDate.subtract(const Duration(days: 10)),
        );
        await dataSource.insertDebt(debt1);
        await dataSource.recordDebtPayment(
          payment: DebtPaymentEntity(
            id: 'pay-v1',
            debtId: 'debt-v1',
            paymentAmount: 50000,
            paidAt: testDate.subtract(const Duration(days: 6)),
          ),
          updatedDebt: debt1,
        );

        // Debt 2: 50 000 F, paid 30 000 F on time, 20 000 F remaining
        final debt2 = DebtEntity(
          id: 'debt-v2',
          debtorId: 'debtor-v',
          initialAmount: 50000,
          remainingAmount: 20000,
          dueDate: testDate.subtract(const Duration(days: 2)),
          status: DebtStatus.active,
          createdAt: testDate.subtract(const Duration(days: 8)),
        );
        await dataSource.insertDebt(debt2);
        await dataSource.recordDebtPayment(
          payment: DebtPaymentEntity(
            id: 'pay-v2',
            debtId: 'debt-v2',
            paymentAmount: 30000,
            paidAt: testDate.subtract(const Duration(days: 3)),
          ),
          updatedDebt: debt2,
        );

        final velocity = await dataSource.getRecoveryVelocity(
          asOf: testDate,
          windowDays: 30,
        );
        expect(velocity.totalDueAmount, 100000);
        expect(velocity.totalRecoveredAmount, 80000);
        expect(velocity.rate, 80);
      },
    );
  });
}
