import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/repositories/sales_repository_impl.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
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

  // Features: Sales & Cash Repository
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(localDataSource: sl<SalesLocalDataSource>()),
  );

  // Features: Sales & Cash Use Cases
  sl.registerLazySingleton<RecordQuickSaleUseCase>(
    () => RecordQuickSaleUseCase(repository: sl<SalesRepository>()),
  );

  // Features: Presentation Cubits / BLoCs
  sl.registerFactory<QuickSaleCubit>(
    () => QuickSaleCubit(recordQuickSaleUseCase: sl<RecordQuickSaleUseCase>()),
  );
}
