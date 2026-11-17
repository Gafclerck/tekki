import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/database/connection/open_connection.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/services/brightness_service.dart';
import 'package:tekki/core/services/geolocator_location_service.dart';
import 'package:tekki/core/services/location_service.dart';
import 'package:tekki/core/services/share_service.dart';
import 'package:tekki/core/services/whatsapp_service.dart';
import 'package:tekki/features/advisor/data/datasources/audio_capsule_local_data_source.dart';
import 'package:tekki/features/advisor/data/repositories/advisor_repository_impl.dart';
import 'package:tekki/features/advisor/data/repositories/audio_capsule_repository_impl.dart';
import 'package:tekki/features/advisor/domain/repositories/advisor_repository.dart';
import 'package:tekki/features/advisor/domain/repositories/audio_capsule_repository.dart';
import 'package:tekki/features/advisor/domain/usecases/evaluate_financial_health_use_case.dart';
import 'package:tekki/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/audio_capsule_cubit.dart';
import 'package:tekki/features/financial_passport/data/datasources/pdf_generator_service_impl.dart';
import 'package:tekki/features/financial_passport/data/repositories/passport_repository_impl.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financial_passport/domain/services/pdf_generator_service.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/share_passport_pdf_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/data/repositories/debt_repository_impl.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
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
  sl.registerLazySingleton<IBrightnessService>(() => ScreenBrightnessService());
  sl.registerLazySingleton<IWhatsAppService>(
    () => const UrlLauncherWhatsAppService(),
  );
  sl.registerLazySingleton<IShareService>(() => const SharePlusService());

  // Core: Cryptography & Secure Storage
  sl.registerLazySingleton<ISecureKeyStorage>(() => FlutterSecureKeyStorage());
  sl.registerLazySingleton<ICryptoSignatureService>(
    () => CryptoSignatureService(secureKeyStorage: sl<ISecureKeyStorage>()),
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
  sl.registerLazySingleton<CalculateRecoveryVelocityUseCase>(
    () => CalculateRecoveryVelocityUseCase(repository: sl<DebtRepository>()),
  );

  // Features: Financial Passport Repository
  sl.registerLazySingleton<PassportRepository>(
    () => PassportRepositoryImpl(
      closureRepository: sl<ClosureRepository>(),
      debtRepository: sl<DebtRepository>(),
    ),
  );

  // Features: Financial Passport Use Cases
  sl.registerLazySingleton<CalculateFinancialPassportUseCase>(
    () =>
        CalculateFinancialPassportUseCase(repository: sl<PassportRepository>()),
  );
  sl.registerLazySingleton<GenerateSignedPassportUseCase>(
    () => GenerateSignedPassportUseCase(
      cryptoSignatureService: sl<ICryptoSignatureService>(),
    ),
  );
  sl.registerLazySingleton<VerifyPassportPayloadUseCase>(
    () => VerifyPassportPayloadUseCase(
      cryptoSignatureService: sl<ICryptoSignatureService>(),
    ),
  );
  sl.registerLazySingleton<IPdfGeneratorService>(
    () => const PdfGeneratorServiceImpl(),
  );
  sl.registerLazySingleton<SharePassportPdfUseCase>(
    () => SharePassportPdfUseCase(
      pdfGeneratorService: sl<IPdfGeneratorService>(),
      shareService: sl<IShareService>(),
    ),
  );

  // Features: Advisor Repository & Use Cases
  sl.registerLazySingleton<AudioCapsuleLocalDataSource>(
    () => const AudioCapsuleLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AudioCapsuleRepository>(
    () => AudioCapsuleRepositoryImpl(
      localDataSource: sl<AudioCapsuleLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetActiveAudioCapsuleUseCase>(
    () =>
        GetActiveAudioCapsuleUseCase(repository: sl<AudioCapsuleRepository>()),
  );
  sl.registerLazySingleton<AdvisorRepository>(
    () => AdvisorRepositoryImpl(
      closureRepository: sl<ClosureRepository>(),
      debtRepository: sl<DebtRepository>(),
    ),
  );
  sl.registerLazySingleton<EvaluateFinancialHealthUseCase>(
    () => EvaluateFinancialHealthUseCase(repository: sl<AdvisorRepository>()),
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
    () =>
        CashDashboardBloc(watchTodaySalesUseCase: sl<WatchTodaySalesUseCase>()),
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
      calculateRecoveryVelocityUseCase: sl<CalculateRecoveryVelocityUseCase>(),
    ),
  );
  sl.registerFactoryParam<CollectDebtPaymentCubit, DebtEntity, void>(
    (debt, _) => CollectDebtPaymentCubit(
      debt: debt,
      recordDebtPaymentUseCase: sl<RecordDebtPaymentUseCase>(),
      audioPlayerService: sl<IAudioPlayerService>(),
    ),
  );
  sl.registerFactory<PassportBloc>(
    () => PassportBloc(
      calculateFinancialPassportUseCase:
          sl<CalculateFinancialPassportUseCase>(),
      generateSignedPassportUseCase: sl<GenerateSignedPassportUseCase>(),
      sharePassportPdfUseCase: sl<SharePassportPdfUseCase>(),
    ),
  );
  sl.registerFactory<AdvisorCubit>(
    () => AdvisorCubit(
      evaluateFinancialHealthUseCase: sl<EvaluateFinancialHealthUseCase>(),
    ),
  );
  sl.registerLazySingleton<AudioCapsuleCubit>(
    () => AudioCapsuleCubit(
      getActiveAudioCapsuleUseCase: sl<GetActiveAudioCapsuleUseCase>(),
      audioPlayerService: sl<IAudioPlayerService>(),
    ),
  );
}
