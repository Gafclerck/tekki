import 'package:flutter_test/flutter_test.dart';

// Core
import 'core/crypto/base45_test.dart' as base45_test;
import 'core/crypto/crypto_signature_service_test.dart'
    as crypto_signature_service_test;
import 'core/crypto/secure_key_storage_test.dart' as secure_key_storage_test;
import 'core/database/app_database_test.dart' as app_database_test;
import 'core/database/daily_closures_table_test.dart'
    as daily_closures_table_test;
import 'core/database/sync_outbox_table_test.dart' as sync_outbox_table_test;
import 'core/network/network_info_test.dart' as network_info_test;
import 'core/services/audio_service_test.dart' as audio_service_test;
import 'core/services/brightness_service_test.dart' as brightness_service_test;
import 'core/services/location_service_test.dart' as location_service_test;
import 'core/services/share_service_test.dart' as share_service_test;
import 'core/services/whatsapp_service_test.dart' as whatsapp_service_test;
import 'core/theme/app_theme_test.dart' as app_theme_test;
import 'core/utils/currency_formatter_test.dart' as currency_formatter_test;
import 'core/utils/haversine_calculator_test.dart' as haversine_calculator_test;
import 'core/utils/result_test.dart' as result_test;

// Features - Advisor
import 'features/advisor/data/repositories/advisor_repository_impl_test.dart'
    as advisor_repository_impl_test;
import 'features/advisor/data/repositories/audio_capsule_repository_impl_test.dart'
    as audio_capsule_repository_impl_test;
import 'features/advisor/domain/usecases/evaluate_financial_health_use_case_test.dart'
    as evaluate_financial_health_use_case_test;
import 'features/advisor/domain/usecases/get_active_audio_capsule_use_case_test.dart'
    as get_active_audio_capsule_use_case_test;
import 'features/advisor/presentation/cubit/advisor_cubit_test.dart'
    as advisor_cubit_test;
import 'features/advisor/presentation/cubit/audio_capsule_cubit_test.dart'
    as audio_capsule_cubit_test;
import 'features/advisor/presentation/pages/advisor_page_test.dart'
    as advisor_page_test;
import 'features/advisor/presentation/widgets/audio_capsule_card_test.dart'
    as audio_capsule_card_test;
import 'features/financial_passport/data/datasources/pdf_generator_service_test.dart'
    as pdf_generator_service_test;
import 'features/financial_passport/data/models/cbor_passport_payload_test.dart'
    as cbor_passport_payload_test;
import 'features/financial_passport/data/repositories/passport_repository_impl_test.dart'
    as passport_repository_impl_test;
import 'features/financial_passport/domain/entities/signed_passport_payload_entity_test.dart'
    as signed_passport_payload_entity_test;
import 'features/financial_passport/domain/usecases/calculate_financial_passport_use_case_test.dart'
    as calculate_financial_passport_use_case_test;
import 'features/financial_passport/domain/usecases/generate_signed_passport_use_case_test.dart'
    as generate_signed_passport_use_case_test;
import 'features/financial_passport/domain/usecases/share_passport_pdf_use_case_test.dart'
    as share_passport_pdf_use_case_test;
import 'features/financial_passport/domain/usecases/verify_passport_payload_use_case_test.dart'
    as verify_passport_payload_use_case_test;
import 'features/financial_passport/presentation/bloc/passport_bloc_share_pdf_test.dart'
    as passport_bloc_share_pdf_test;
import 'features/financial_passport/presentation/bloc/passport_bloc_test.dart'
    as passport_bloc_test;
import 'features/financial_passport/presentation/pages/passport_overview_page_share_test.dart'
    as passport_overview_page_share_test;
import 'features/financial_passport/presentation/pages/passport_overview_page_test.dart'
    as passport_overview_page_test;
import 'features/financial_passport/presentation/widgets/passport_fullscreen_qr_dialog_test.dart'
    as passport_fullscreen_qr_dialog_test;
import 'features/financial_passport/presentation/widgets/passport_qr_card_test.dart'
    as passport_qr_card_test;

// Features - Karne Bor
import 'features/karne_bor/data/datasources/debt_local_data_source_test.dart'
    as debt_local_data_source_test;
import 'features/karne_bor/domain/services/whatsapp_reminder_template_test.dart'
    as whatsapp_reminder_template_test;
import 'features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case_test.dart'
    as calculate_recovery_velocity_use_case_test;
import 'features/karne_bor/domain/usecases/record_debt_payment_use_case_test.dart'
    as record_debt_payment_use_case_test;
import 'features/karne_bor/domain/usecases/record_debt_use_case_test.dart'
    as record_debt_use_case_test;
import 'features/karne_bor/presentation/cubit/collect_debt_payment_cubit_test.dart'
    as collect_debt_payment_cubit_test;
import 'features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart'
    as karne_bor_cubit_test;
import 'features/karne_bor/presentation/cubit/record_debt_cubit_test.dart'
    as record_debt_cubit_test;
import 'features/karne_bor/presentation/screens/karne_bor_screen_test.dart'
    as karne_bor_screen_test;
import 'features/karne_bor/presentation/widgets/collect_debt_payment_dialog_test.dart'
    as collect_debt_payment_dialog_test;
import 'features/karne_bor/presentation/widgets/debt_card_test.dart'
    as debt_card_test;
import 'features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet_test.dart'
    as whatsapp_reminder_bottom_sheet_test;

// Features - Sales and Cash
import 'features/sales_and_cash/closure_cash_reconciliation_test.dart'
    as closure_cash_reconciliation_test;
import 'features/sales_and_cash/data/repositories/closure_repository_impl_test.dart'
    as closure_repository_impl_test;
import 'features/sales_and_cash/data/repositories/sales_repository_impl_test.dart'
    as sales_repository_impl_test;
import 'features/sales_and_cash/domain/usecases/execute_daily_closure_use_case_test.dart'
    as execute_daily_closure_use_case_test;
import 'features/sales_and_cash/domain/usecases/record_quick_sale_use_case_test.dart'
    as record_quick_sale_use_case_test;
import 'features/sales_and_cash/domain/usecases/watch_today_sales_use_case_test.dart'
    as watch_today_sales_use_case_test;
import 'features/sales_and_cash/presentation/bloc/cash_dashboard_bloc_test.dart'
    as cash_dashboard_bloc_test;
import 'features/sales_and_cash/presentation/cubit/express_closure_cubit_test.dart'
    as express_closure_cubit_test;
import 'features/sales_and_cash/presentation/cubit/quick_sale_cubit_test.dart'
    as quick_sale_cubit_test;
import 'features/sales_and_cash/presentation/screens/express_closure_screen_test.dart'
    as express_closure_screen_test;
import 'features/sales_and_cash/presentation/screens/home_screen_test.dart'
    as home_screen_test;
import 'features/sales_and_cash/presentation/widgets/cash_card_test.dart'
    as cash_card_test;
import 'features/sales_and_cash/presentation/widgets/primary_cta_button_test.dart'
    as primary_cta_button_test;
import 'features/sales_and_cash/presentation/widgets/quick_sale_bottom_sheet_test.dart'
    as quick_sale_bottom_sheet_test;

// Features - Sync
import 'features/sync/data/datasources/outbox_local_data_source_test.dart'
    as outbox_local_data_source_test;
import 'features/sync/data/datasources/remote_sync_api_client_test.dart'
    as remote_sync_api_client_test;
import 'features/sync/data/repositories/sync_repository_impl_test.dart'
    as sync_repository_impl_test;
import 'features/sync/data/services/sync_orchestrator_test.dart'
    as sync_orchestrator_test;
import 'features/sync/domain/usecases/process_outbox_queue_use_case_test.dart'
    as process_outbox_queue_use_case_test;
import 'features/sync/presentation/cubit/sync_cubit_test.dart'
    as sync_cubit_test;
import 'features/sync/presentation/widgets/sync_status_indicator_test.dart'
    as sync_status_indicator_test;

// General Widget Test
import 'widget_test.dart' as widget_test;

void main() {
  group('Tekki Full Test Suite', () {
    // Core
    group('Core Tests', () {
      base45_test.main();
      crypto_signature_service_test.main();
      secure_key_storage_test.main();
      app_database_test.main();
      daily_closures_table_test.main();
      sync_outbox_table_test.main();
      network_info_test.main();
      audio_service_test.main();
      brightness_service_test.main();
      location_service_test.main();
      share_service_test.main();
      whatsapp_service_test.main();
      app_theme_test.main();
      currency_formatter_test.main();
      haversine_calculator_test.main();
      result_test.main();
    });

    // Features - Financial Passport
    group('Features: Financial Passport Tests', () {
      cbor_passport_payload_test.main();
      calculate_financial_passport_use_case_test.main();
      signed_passport_payload_entity_test.main();
      generate_signed_passport_use_case_test.main();
      passport_repository_impl_test.main();
      verify_passport_payload_use_case_test.main();
      pdf_generator_service_test.main();
      share_passport_pdf_use_case_test.main();
      passport_bloc_test.main();
      passport_bloc_share_pdf_test.main();
      passport_qr_card_test.main();
      passport_fullscreen_qr_dialog_test.main();
      passport_overview_page_test.main();
      passport_overview_page_share_test.main();
    });

    // Features - Advisor
    group('Features: Advisor Tests', () {
      evaluate_financial_health_use_case_test.main();
      get_active_audio_capsule_use_case_test.main();
      advisor_repository_impl_test.main();
      audio_capsule_repository_impl_test.main();
      advisor_cubit_test.main();
      audio_capsule_cubit_test.main();
      advisor_page_test.main();
      audio_capsule_card_test.main();
    });

    // Features - Karne Bor
    group('Features: Karne Bor Tests', () {
      debt_local_data_source_test.main();
      whatsapp_reminder_template_test.main();
      calculate_recovery_velocity_use_case_test.main();
      record_debt_payment_use_case_test.main();
      record_debt_use_case_test.main();
      collect_debt_payment_cubit_test.main();
      karne_bor_cubit_test.main();
      record_debt_cubit_test.main();
      karne_bor_screen_test.main();
      collect_debt_payment_dialog_test.main();
      debt_card_test.main();
      whatsapp_reminder_bottom_sheet_test.main();
    });

    // Features - Sales and Cash
    group('Features: Sales & Cash Tests', () {
      closure_cash_reconciliation_test.main();
      closure_repository_impl_test.main();
      sales_repository_impl_test.main();
      execute_daily_closure_use_case_test.main();
      record_quick_sale_use_case_test.main();
      watch_today_sales_use_case_test.main();
      cash_dashboard_bloc_test.main();
      express_closure_cubit_test.main();
      quick_sale_cubit_test.main();
      express_closure_screen_test.main();
      home_screen_test.main();
      cash_card_test.main();
      primary_cta_button_test.main();
      quick_sale_bottom_sheet_test.main();
    });

    // Features - Sync
    group('Features: Sync Tests', () {
      outbox_local_data_source_test.main();
      remote_sync_api_client_test.main();
      sync_repository_impl_test.main();
      sync_orchestrator_test.main();
      process_outbox_queue_use_case_test.main();
      sync_cubit_test.main();
      sync_status_indicator_test.main();
    });

    // App Widget Test
    group('App Widget Tests', () {
      widget_test.main();
    });
  });
}
