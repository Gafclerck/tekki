abstract final class AppConstants {
  static const String appName = 'Tekki';
  static const String appVersion = '0.1.0';

  // Currency
  static const String currencyCode = 'XOF';
  static const String currencySymbol = 'FCFA';

  // Limits and thresholds
  static const int defaultPaginationLimit = 50;
  static const double shopGeofenceRadiusMeters = 200.0;
  static const int locationTimeoutSeconds = 5;

  // Sync configuration
  static const int defaultSyncIntervalMinutes = 15;
  static const int defaultSyncBatchSize = 50;
  static const String defaultSyncEndpoint =
      'https://api.tekki.app/v1/sync/batch';
  static const int syncMaxRetryCount = 10;
  static const int syncInitialBackoffSeconds = 5;
  static const int syncMaxBackoffMinutes = 15;
}
