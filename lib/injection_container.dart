import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/services/geolocator_location_service.dart';
import 'package:tekki/core/services/location_service.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/data/repositories/debt_repository_impl.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/record_debt_cubit.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/repositories/closure_repository_impl.dart';
import 'package:tekki/features/sales_and_cash/data/repositories/sales_repository_impl.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/quick_sale_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection({
  AppDatabase? database,
  bool inMemoryDatabase = false,
}) async {
  // Core: Network
  sl.registerLazySingleton<Connectivity>(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // Core: Hardware & Device Services
  sl.registerLazySingleton<ILocationService>(() => GeolocatorLocationService());
  sl.registerLazySingleton<IAudioPlayerService>(() => JustAudioPlayerService());

  // Core: Persistence Drift SQLite
  sl.registerLazySingleton<AppDatabase>(
    () =>
        database ??
        AppDatabase(inMemoryDatabase ? openConnection(inMemory: true) : null),
  );

  // Features: Sales & Cash Local Data Source
  sl.registerLazySingleton<SalesLocalDataSource>(
    () => SalesLocalDataSourceImpl(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ClosureLocalDataSource>(
    () => ClosureLocalDataSourceImpl(database: sl<AppDatabase>()),
  );

  // Features: Sales & Cash Repository
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(localDataSource: sl<SalesLocalDataSource>()),
  );
  sl.registerLazySingleton<ClosureRepository>(
    () => ClosureRepositoryImpl(localDataSource: sl<ClosureLocalDataSource>()),
  );

  // Features: Sales & Cash Use Cases
  sl.registerLazySingleton<RecordQuickSaleUseCase>(
    () => RecordQuickSaleUseCase(repository: sl<SalesRepository>()),
  );
  sl.registerLazySingleton<WatchTodaySalesUseCase>(
    () => WatchTodaySalesUseCase(repository: sl<SalesRepository>()),
  );
  sl.registerLazySingleton<GetClosurePrefillUseCase>(
    () => GetClosurePrefillUseCase(repository: sl<ClosureRepository>()),
  );
  sl.registerLazySingleton<ExecuteDailyClosureUseCase>(
    () => ExecuteDailyClosureUseCase(
      repository: sl<ClosureRepository>(),
      locationService: sl<ILocationService>(),
    ),
  );

  // Features: Karné Bor Local Data Source
  sl.registerLazySingleton<DebtLocalDataSource>(
    () => DebtLocalDataSourceImpl(database: sl<AppDatabase>()),
  );

  // Features: Karné Bor Repository
  sl.registerLazySingleton<DebtRepository>(
    () => DebtRepositoryImpl(localDataSource: sl<DebtLocalDataSource>()),
  );

  // Features: Karné Bor Use Cases
  sl.registerLazySingleton<RecordDebtUseCase>(
    () => RecordDebtUseCase(repository: sl<DebtRepository>()),
  );
  sl.registerLazySingleton<WatchActiveDebtsUseCase>(
    () => WatchActiveDebtsUseCase(repository: sl<DebtRepository>()),
  );
  sl.registerLazySingleton<GetDebtorsUseCase>(
    () => GetDebtorsUseCase(repository: sl<DebtRepository>()),
  );
  sl.registerLazySingleton<RecordDebtPaymentUseCase>(
    () => RecordDebtPaymentUseCase(repository: sl<DebtRepository>()),
  );

  // Features: Presentation Cubits / BLoCs
  sl.registerFactory<QuickSaleCubit>(
    () => QuickSaleCubit(recordQuickSaleUseCase: sl<RecordQuickSaleUseCase>()),
  );
  sl.registerFactory<ExpressClosureCubit>(
    () => ExpressClosureCubit(
      getClosurePrefillUseCase: sl<GetClosurePrefillUseCase>(),
      executeDailyClosureUseCase: sl<ExecuteDailyClosureUseCase>(),
      closureRepository: sl<ClosureRepository>(),
      audioPlayerService: sl<IAudioPlayerService>(),
    ),
  );
  sl.registerFactory<CashDashboardBloc>(
    () => CashDashboardBloc(
      watchTodaySalesUseCase: sl<WatchTodaySalesUseCase>(),
    ),
  );
  sl.registerFactory<RecordDebtCubit>(
    () => RecordDebtCubit(
      recordDebtUseCase: sl<RecordDebtUseCase>(),
      getDebtorsUseCase: sl<GetDebtorsUseCase>(),
    ),
  );
  sl.registerFactory<KarneBorCubit>(
    () => KarneBorCubit(
      watchActiveDebtsUseCase: sl<WatchActiveDebtsUseCase>(),
    ),
  );
  sl.registerFactoryParam<CollectDebtPaymentCubit, DebtEntity, void>(
    (debt, _) => CollectDebtPaymentCubit(
      debt: debt,
      recordDebtPaymentUseCase: sl<RecordDebtPaymentUseCase>(),
      audioPlayerService: sl<IAudioPlayerService>(),
    ),
  );
}
