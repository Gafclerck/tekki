import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tekki/core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Core: Network
  sl.registerLazySingleton<Connectivity>(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
}
