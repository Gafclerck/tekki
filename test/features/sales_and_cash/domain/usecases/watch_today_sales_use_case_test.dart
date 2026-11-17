import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

void main() {
  late MockSalesRepository mockRepository;
  late StreamController<List<SaleEntity>> streamController;
  late WatchTodaySalesUseCase useCase;

  final fixedNow = DateTime(2026, 11, 17, 14, 30); // 17 Nov 2026

  setUp(() {
    mockRepository = MockSalesRepository();
    streamController = StreamController<List<SaleEntity>>.broadcast();
    when(() => mockRepository.watchOrphanSales())
        .thenAnswer((_) => streamController.stream);

    useCase = WatchTodaySalesUseCase(
      repository: mockRepository,
      nowProvider: () => fixedNow,
    );
  });

  tearDown(() async {
    await streamController.close();
  });

  group('WatchTodaySalesUseCase', () {
    test('emits empty summary when repository emits empty list', () async {
      unawaited(
        expectLater(
          useCase(),
          emits(
            predicate<CashSummaryEntity>(
              (summary) =>
                  summary.totalAmount == 0 &&
                  summary.salesCount == 0 &&
                  summary.sales.isEmpty,
            ),
          ),
        ),
      );

      streamController.add([]);
    });

    test('cumulates today orphan sales correctly', () async {
      final sale1 = SaleEntity(
        id: 'sale-1',
        amount: 5000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 8, 30),
      );
      final sale2 = SaleEntity(
        id: 'sale-2',
        amount: 2500,
        paymentMethod: PaymentMethod.mobileMoney,
        recordedAt: DateTime(2026, 11, 17, 10, 15),
      );
      final sale3 = SaleEntity(
        id: 'sale-3',
        amount: 10000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 12, 0),
      );

      unawaited(
        expectLater(
          useCase(),
          emits(
            predicate<CashSummaryEntity>(
              (summary) =>
                  summary.totalAmount == 17500 &&
                  summary.salesCount == 3 &&
                  summary.sales.length == 3,
            ),
          ),
        ),
      );

      streamController.add([sale1, sale2, sale3]);
    });

    test('excludes sales from previous days', () async {
      final yesterdaySale = SaleEntity(
        id: 'sale-yesterday',
        amount: 8000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 16, 18, 0),
      );
      final todaySale = SaleEntity(
        id: 'sale-today',
        amount: 4000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 9, 0),
      );

      unawaited(
        expectLater(
          useCase(),
          emits(
            predicate<CashSummaryEntity>(
              (summary) =>
                  summary.totalAmount == 4000 &&
                  summary.salesCount == 1 &&
                  summary.sales.first.id == 'sale-today',
            ),
          ),
        ),
      );

      streamController.add([yesterdaySale, todaySale]);
    });

    test('excludes sales that already have closureId != null', () async {
      final closedSale = SaleEntity(
        id: 'sale-closed',
        amount: 5000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 9, 0),
        closureId: 'closure-123',
      );
      final orphanSale = SaleEntity(
        id: 'sale-orphan',
        amount: 3000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 11, 0),
      );

      unawaited(
        expectLater(
          useCase(),
          emits(
            predicate<CashSummaryEntity>(
              (summary) =>
                  summary.totalAmount == 3000 &&
                  summary.salesCount == 1 &&
                  summary.sales.first.id == 'sale-orphan',
            ),
          ),
        ),
      );

      streamController.add([closedSale, orphanSale]);
    });

    test(
      'reactively emits updated totals as new sales arrive via stream',
      () async {
        final sale1 = SaleEntity(
          id: 'sale-1',
          amount: 5000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime(2026, 11, 17, 8, 0),
        );
        final sale2 = SaleEntity(
          id: 'sale-2',
          amount: 2500,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime(2026, 11, 17, 9, 0),
        );
        final sale3 = SaleEntity(
          id: 'sale-3',
          amount: 10000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime(2026, 11, 17, 10, 0),
        );
        final newSale = SaleEntity(
          id: 'sale-4',
          amount: 3000,
          paymentMethod: PaymentMethod.especes,
          recordedAt: DateTime(2026, 11, 17, 11, 0),
        );

        final expectations = [
          predicate<CashSummaryEntity>(
            (summary) =>
                summary.totalAmount == 17500 && summary.salesCount == 3,
          ),
          predicate<CashSummaryEntity>(
            (summary) =>
                summary.totalAmount == 20500 && summary.salesCount == 4,
          ),
        ];

        unawaited(expectLater(useCase(), emitsInOrder(expectations)));

        streamController.add([sale1, sale2, sale3]);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        streamController.add([sale1, sale2, sale3, newSale]);
      },
    );
  });
}
