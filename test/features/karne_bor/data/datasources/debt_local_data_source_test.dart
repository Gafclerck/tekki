import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
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
      'recordDebtWithDebtor persists both debtor and debt atomically',
      () async {
        final debtor = DebtorEntity(
          id: 'debtor-atom-1',
          name: 'Ibrahima Fall',
          phoneNumber: '781112233',
          createdAt: testDate,
        );

        final debt = DebtEntity(
          id: 'debt-atom-1',
          debtorId: 'debtor-atom-1',
          initialAmount: 7500,
          remainingAmount: 7500,
          dueDate: testDate.add(const Duration(days: 5)),
          status: DebtStatus.active,
          syncStatus: 'pending',
          createdAt: testDate,
        );

        await dataSource.recordDebtWithDebtor(
          debtor: debtor,
          debt: debt,
          isNewDebtor: true,
        );

        final retrievedDebtor = await dataSource.getDebtorById('debtor-atom-1');
        final retrievedDebt = await dataSource.getDebtById('debt-atom-1');

        expect(retrievedDebtor, isNotNull);
        expect(retrievedDebt, isNotNull);
        expect(retrievedDebt?.initialAmount, 7500);
        expect(retrievedDebt?.debtor?.name, 'Ibrahima Fall');
      },
    );

    test('recordDebtWithDebtor rolls back completely when debt insertion fails', () async {
      // First insert a debt with id 'duplicate-debt-id'
      final debtor0 = DebtorEntity(
        id: 'debtor-pre-0',
        name: 'Existing Debtor',
        createdAt: testDate,
      );
      final debt0 = DebtEntity(
        id: 'duplicate-debt-id',
        debtorId: 'debtor-pre-0',
        initialAmount: 1000,
        remainingAmount: 1000,
        dueDate: testDate,
        createdAt: testDate,
      );
      await dataSource.recordDebtWithDebtor(debtor: debtor0, debt: debt0);

      // Now attempt atomic transaction with a NEW debtor and DUPLICATE debt ID
      final newDebtor = DebtorEntity(
        id: 'new-debtor-should-rollback',
        name: 'Rollback Candidate',
        createdAt: testDate,
      );
      final duplicateDebt = DebtEntity(
        id: 'duplicate-debt-id', // duplicate PK will trigger failure
        debtorId: 'new-debtor-should-rollback',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: testDate,
        createdAt: testDate,
      );

      expect(
        () => dataSource.recordDebtWithDebtor(
          debtor: newDebtor,
          debt: duplicateDebt,
          isNewDebtor: true,
        ),
        throwsA(isA<DatabaseException>()),
      );

      // Verify atomicity: newDebtor was NOT persisted!
      final shouldBeNull = await dataSource.getDebtorById(
        'new-debtor-should-rollback',
      );
      expect(shouldBeNull, isNull);
    });

    test('watchActiveDebts emits active debts ordered by due_date', () async {
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
      final debtLater = DebtEntity(
        id: 'stream-debt-later',
        debtorId: 'stream-debtor-1',
        initialAmount: 5000,
        remainingAmount: 5000,
        dueDate: testDate.add(const Duration(days: 10)),
        status: DebtStatus.active,
        createdAt: testDate,
      );

      final expectation = expectLater(
        dataSource.watchActiveDebts(),
        emitsInOrder([isEmpty, hasLength(1), hasLength(2)]),
      );

      // Allow stream setup
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await dataSource.insertDebt(debtLater);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await dataSource.insertDebt(debtSoon);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await expectation;
    });
  });
}
