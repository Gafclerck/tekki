import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';

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
}
