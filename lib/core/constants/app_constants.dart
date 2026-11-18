abstract final class AppConstants {
  static const String appName = 'Tekki';
  static const String appVersion = '0.1.0';

  // Currency
  static const String currencyCode = 'XOF';
  static const String currencySymbol = 'FCFA';

  // Branding Assets
  static const String logoHorizontalPng = 'assets/branding/logo_horizontal.png';
  static const String logoHorizontalSvg = 'assets/branding/logo_horizontal.svg';
  static const String logoSymbolPng = 'assets/branding/logo_symbol.png';
  static const String logoSymbolSvg = 'assets/branding/logo_symbol.svg';
  static const String appIconAndroidSquare =
      'assets/branding/app_icon_android_square.png';
  static const String appIconAndroidCircle =
      'assets/branding/app_icon_android_circle.png';
  static const String avatarSocialPng = 'assets/branding/avatar_social.png';
  static const String qrCodeAsset = 'assets/branding/qr_code.png';

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
