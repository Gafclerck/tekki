import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/services/demo_data_seeder.dart';

void main() {
  late AppDatabase db;
  late DemoDataSeederService seeder;

  setUp(() {
    db = AppDatabase.forTesting(openConnection(inMemory: true));
    seeder = DemoDataSeederService(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DemoDataSeederService Unit Tests', () {
    test(
      'seedCompleteTestData populates all tables with realistic data',
      () async {
        await seeder.seedCompleteTestData();

        // Check shops
        final shops = await db.select(db.shops).get();
        expect(shops.length, equals(1));
        expect(shops.first.name, equals('Boutique Keur Serigne Bi'));

        // Check daily closures (14 consecutive days)
        final closures = await db.select(db.dailyClosures).get();
        expect(closures.length, equals(14));

        // Check sales
        final sales = await db.select(db.sales).get();
        expect(sales.length, greaterThanOrEqualTo(28));

        // Check debtors and debts
        final debtors = await db.select(db.debtors).get();
        expect(debtors.length, equals(4));

        final debts = await db.select(db.debts).get();
        expect(debts.length, equals(4));

        final payments = await db.select(db.debtPayments).get();
        expect(payments.length, equals(2));

        // Check loan applications
        final applications = await db.select(db.loanApplications).get();
        expect(applications.length, equals(2));
        expect(applications.any((a) => a.partnerId == 'baobab_sn'), isTrue);
        expect(applications.any((a) => a.partnerId == 'cofina_sn'), isTrue);
      },
    );

    test('clearAllData removes all records from dynamic tables', () async {
      await seeder.seedCompleteTestData();
      await seeder.clearAllData();

      expect(await db.select(db.dailyClosures).get(), isEmpty);
      expect(await db.select(db.sales).get(), isEmpty);
      expect(await db.select(db.debtors).get(), isEmpty);
      expect(await db.select(db.debts).get(), isEmpty);
      expect(await db.select(db.loanApplications).get(), isEmpty);
    });
  });
}
