import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/cash_summary_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/payment_method.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/sale_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';

class MockWatchTodaySalesUseCase extends Mock
    implements WatchTodaySalesUseCase {}

void main() {
  late MockWatchTodaySalesUseCase mockUseCase;
  late StreamController<CashSummaryEntity> streamController;

  final sampleSale1 = SaleEntity(
    id: 'sale-1',
    amount: 5000,
    paymentMethod: PaymentMethod.especes,
    recordedAt: DateTime(2026, 11, 17, 8, 0),
  );
  final sampleSale2 = SaleEntity(
    id: 'sale-2',
    amount: 2500,
    paymentMethod: PaymentMethod.especes,
    recordedAt: DateTime(2026, 11, 17, 9, 0),
  );
  final sampleSale3 = SaleEntity(
    id: 'sale-3',
    amount: 10000,
    paymentMethod: PaymentMethod.especes,
    recordedAt: DateTime(2026, 11, 17, 10, 0),
  );

  const summaryEmpty = CashSummaryEntity.empty();
  final summary3Sales = CashSummaryEntity(
    totalAmount: 17500,
    salesCount: 3,
    sales: [sampleSale1, sampleSale2, sampleSale3],
  );
  final summary4Sales = CashSummaryEntity(
    totalAmount: 20500,
    salesCount: 4,
    sales: [
      sampleSale1,
      sampleSale2,
      sampleSale3,
      SaleEntity(
        id: 'sale-4',
        amount: 3000,
        paymentMethod: PaymentMethod.especes,
        recordedAt: DateTime(2026, 11, 17, 11, 0),
      ),
    ],
  );

  setUp(() {
    mockUseCase = MockWatchTodaySalesUseCase();
    streamController = StreamController<CashSummaryEntity>.broadcast();
    when(() => mockUseCase()).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  group('CashDashboardBloc', () {
    test('initial state is CashDashboardInitial', () {
      final bloc = CashDashboardBloc(watchTodaySalesUseCase: mockUseCase);
      expect(bloc.state, equals(const CashDashboardInitial()));
      bloc.close();
    });

    blocTest<CashDashboardBloc, CashDashboardState>(
      'emits [CashDashboardLoading, CashDashboardLoaded] when stream emits',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      act: (bloc) async {
        bloc.add(const WatchCashDashboardStarted());
        await Future<void>.delayed(Duration.zero);
        streamController.add(summaryEmpty);
      },
      expect: () => [
        const CashDashboardLoading(),
        const CashDashboardLoaded(
          summary: summaryEmpty,
          isClosureLocked: false,
        ),
      ],
    );

    blocTest<CashDashboardBloc, CashDashboardState>(
      'reactively emits updated CashDashboardLoaded when stream pushes new sales',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      act: (bloc) async {
        bloc.add(const WatchCashDashboardStarted());
        await Future<void>.delayed(Duration.zero);
        streamController.add(summary3Sales);
        await Future<void>.delayed(Duration.zero);
        streamController.add(summary4Sales);
      },
      expect: () => [
        const CashDashboardLoading(),
        CashDashboardLoaded(summary: summary3Sales, isClosureLocked: false),
        CashDashboardLoaded(summary: summary4Sales, isClosureLocked: false),
      ],
    );

    blocTest<CashDashboardBloc, CashDashboardState>(
      'emits CashDashboardError when stream emits an error',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      act: (bloc) async {
        bloc.add(const WatchCashDashboardStarted());
        await Future<void>.delayed(Duration.zero);
        streamController.addError('Database stream failure');
      },
      expect: () => [
        const CashDashboardLoading(),
        const CashDashboardError(
          message:
              'Erreur lors de la lecture de la caisse : Database stream failure',
        ),
      ],
    );

    blocTest<CashDashboardBloc, CashDashboardState>(
      'handles CloseCashierTapped and locks closure (anti-double-click)',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      seed: () =>
          CashDashboardLoaded(summary: summary3Sales, isClosureLocked: false),
      act: (bloc) {
        bloc.add(const CloseCashierTapped());
        // Second tap should be ignored because already locked
        bloc.add(const CloseCashierTapped());
      },
      expect: () => [
        CashDashboardLoaded(summary: summary3Sales, isClosureLocked: true),
      ],
    );

    blocTest<CashDashboardBloc, CashDashboardState>(
      'preserves isClosureLocked=true when stream emits new sales after locking',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      act: (bloc) async {
        bloc.add(const WatchCashDashboardStarted());
        await Future<void>.delayed(Duration.zero);
        streamController.add(summary3Sales);
        await Future<void>.delayed(Duration.zero);
        bloc.add(const CloseCashierTapped());
        await Future<void>.delayed(Duration.zero);
        streamController.add(summary4Sales);
      },
      expect: () => [
        const CashDashboardLoading(),
        CashDashboardLoaded(summary: summary3Sales, isClosureLocked: false),
        CashDashboardLoaded(summary: summary3Sales, isClosureLocked: true),
        CashDashboardLoaded(summary: summary4Sales, isClosureLocked: true),
      ],
    );

    blocTest<CashDashboardBloc, CashDashboardState>(
      'handles ResetClosureLock and unlocks closure when previously locked',
      build: () => CashDashboardBloc(watchTodaySalesUseCase: mockUseCase),
      seed: () =>
          CashDashboardLoaded(summary: summary3Sales, isClosureLocked: true),
      act: (bloc) => bloc.add(const ResetClosureLock()),
      expect: () => [
        CashDashboardLoaded(summary: summary3Sales, isClosureLocked: false),
      ],
    );
  });
}
