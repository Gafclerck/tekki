import 'package:bloc_test/bloc_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/crypto/crypto_signature_service.dart';
import 'package:tekki/core/crypto/secure_key_storage.dart';
import 'package:tekki/core/network/network_info.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/services/brightness_service.dart';
import 'package:tekki/core/services/location_service.dart';
import 'package:tekki/core/services/share_service.dart';
import 'package:tekki/core/services/whatsapp_service.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/domain/entities/health_indicator_entity.dart';
import 'package:tekki/features/advisor/domain/repositories/advisor_repository.dart';
import 'package:tekki/features/advisor/domain/usecases/evaluate_financial_health_use_case.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';
import 'package:tekki/features/financial_passport/domain/entities/financial_passport_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/score_breakdown_entity.dart';
import 'package:tekki/features/financial_passport/domain/entities/signed_passport_payload_entity.dart';
import 'package:tekki/features/financial_passport/domain/repositories/passport_repository.dart';
import 'package:tekki/features/financial_passport/domain/services/pdf_generator_service.dart';
import 'package:tekki/features/financial_passport/domain/usecases/calculate_financial_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/share_passport_pdf_use_case.dart';
import 'package:tekki/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_bloc.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_event.dart';
import 'package:tekki/features/financial_passport/presentation/bloc/passport_state.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/get_debtors_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:tekki/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/karne_bor_state.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/closure_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/data/datasources/sales_local_data_source.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/sales_repository.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/get_closure_prefill_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/record_quick_sale_use_case.dart';
import 'package:tekki/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart';
import 'package:tekki/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart';
import 'package:uuid/uuid.dart';

// Repositories
class MockClosureRepository extends Mock implements ClosureRepository {}

class MockAdvisorRepository extends Mock implements AdvisorRepository {}

class MockSalesRepository extends Mock implements SalesRepository {}

class MockDebtRepository extends Mock implements DebtRepository {}

class MockPassportRepository extends Mock implements PassportRepository {}

// Data Sources
class MockSalesLocalDataSource extends Mock implements SalesLocalDataSource {}

class MockClosureLocalDataSource extends Mock
    implements ClosureLocalDataSource {}

class MockDebtLocalDataSource extends Mock implements DebtLocalDataSource {}

// Services & Core
class MockLocationService extends Mock implements ILocationService {}

class MockSecureKeyStorage extends Mock implements ISecureKeyStorage {}

class MockCryptoSignatureService extends Mock
    implements ICryptoSignatureService {}

class MockAudioPlayerService extends Mock implements IAudioPlayerService {}

class MockBrightnessService extends Mock implements IBrightnessService {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockWhatsAppService extends Mock implements IWhatsAppService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockUuid extends Mock implements Uuid {}

// Use Cases - Karne Bor
class MockWatchActiveDebtsUseCase extends Mock
    implements WatchActiveDebtsUseCase {}

class MockRecordDebtUseCase extends Mock implements RecordDebtUseCase {}

class MockGetDebtorsUseCase extends Mock implements GetDebtorsUseCase {}

class MockRecordDebtPaymentUseCase extends Mock
    implements RecordDebtPaymentUseCase {}

class MockCalculateRecoveryVelocityUseCase extends Mock
    implements CalculateRecoveryVelocityUseCase {}

// Use Cases - Sales & Cash
class MockRecordQuickSaleUseCase extends Mock
    implements RecordQuickSaleUseCase {}

class MockWatchTodaySalesUseCase extends Mock
    implements WatchTodaySalesUseCase {}

class MockExecuteDailyClosureUseCase extends Mock
    implements ExecuteDailyClosureUseCase {}

class MockGetClosurePrefillUseCase extends Mock
    implements GetClosurePrefillUseCase {}

// Use Cases - Financial Passport
class MockCalculateFinancialPassportUseCase extends Mock
    implements CalculateFinancialPassportUseCase {}

class MockGenerateSignedPassportUseCase extends Mock
    implements GenerateSignedPassportUseCase {}

class MockVerifyPassportPayloadUseCase extends Mock
    implements VerifyPassportPayloadUseCase {}

// BLoC & Cubits
class MockCashDashboardBloc
    extends MockBloc<CashDashboardEvent, CashDashboardState>
    implements CashDashboardBloc {}

class MockKarneBorCubit extends MockCubit<KarneBorState>
    implements KarneBorCubit {}

class MockPassportBloc extends MockBloc<PassportEvent, PassportState>
    implements PassportBloc {}

class MockAdvisorCubit extends MockCubit<AdvisorState>
    implements AdvisorCubit {}

// Services
class MockShareService extends Mock implements IShareService {}

class MockPdfGeneratorService extends Mock implements IPdfGeneratorService {}

class MockSharePassportPdfUseCase extends Mock
    implements SharePassportPdfUseCase {}

class MockEvaluateFinancialHealthUseCase extends Mock
    implements EvaluateFinancialHealthUseCase {}

// Fakes for Mocktail registerFallbackValue
class FakeDailyClosureEntity extends Fake implements DailyClosureEntity {}

class FakeDebtEntity extends Fake implements DebtEntity {}

class FakeDebtorEntity extends Fake implements DebtorEntity {}

class FakeRecordDebtParams extends Fake implements RecordDebtParams {}

class FakeFinancialPassportEntity extends Fake
    implements FinancialPassportEntity {}

class FakeSignedPassportPayloadEntity extends Fake
    implements SignedPassportPayloadEntity {}

class FakeScoreBreakdownEntity extends Fake implements ScoreBreakdownEntity {}

class FakePassportEvent extends Fake implements PassportEvent {}

class FakePassportState extends Fake implements PassportState {}

class FakeFinancialHealthEntity extends Fake implements FinancialHealthEntity {}

class FakeHealthIndicatorEntity extends Fake implements HealthIndicatorEntity {}

class FakeAdvisorState extends Fake implements AdvisorState {}
