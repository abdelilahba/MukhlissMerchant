/// Application-wide constants and configuration values.
/// 
/// Centralizes all magic numbers and configuration values for better
/// maintainability and consistency across the codebase.
/// 
/// Usage:
/// ```dart
/// import 'package:mukhlissmagasin/core/constants/app_constants.dart';
/// 
/// final points = montant * AppConstants.pointsPerMAD;
/// ```
library;

/// Business and app configuration constants
class AppConstants {
  AppConstants._(); // Private constructor

  // ========== APP INFO ==========
  /// Application name
  static const String appName = 'Mukhliss Merchant';
  
  /// Current app version
  static const String appVersion = '1.0.0';
  
  /// Build number
  static const int buildNumber = 1;

  // ========== BUSINESS RULES ==========
  /// Points earned per MAD spent (10 MAD = 1 point)
  static const double pointsPerMAD = 0.1;
  
  /// Minimum transaction amount in MAD
  static const double minTransactionAmount = 1.0;
  
  /// Maximum rewards claimable per transaction
  static const int maxRewardsPerTransaction = 5;
  
  /// Points rounding mode (floor = toward zero)
  static const int pointsRoundingMode = 0; // 0 = floor

  // ========== CACHE SETTINGS ==========
  /// Cache expiration duration
  static const Duration cacheExpiration = Duration(minutes: 15);
  
  /// Maximum cache size (number of entries)
  static const int maxCacheSize = 100;
  
  /// Subscription check interval
  static const Duration subscriptionCheckInterval = Duration(hours: 1);

  // ========== API TIMEOUTS ==========
  /// API connection timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// API receive timeout
  static const Duration apiReceiveTimeout = Duration(seconds: 60);

  // ========== UI SETTINGS ==========
  /// Default animation duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Fast animation duration
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  
  /// Slow animation duration
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  /// Default padding value
  static const double defaultPadding = 16.0;
  
  /// Small padding value
  static const double paddingSmall = 8.0;
  
  /// Large padding value
  static const double paddingLarge = 24.0;
  
  /// Default border radius
  static const double defaultRadius = 8.0;
  
  /// Large border radius
  static const double radiusLarge = 16.0;
  
  /// Extra large border radius
  static const double radiusXLarge = 24.0;

  // ========== QR CODE SETTINGS ==========
  /// QR code scan delay before processing
  static const Duration qrScanDelay = Duration(milliseconds: 500);
  
  /// QR code prefix for client codes
  static const String qrCodePrefix = 'MUKHLISS_';

  // ========== SUPPORTED LOCALES ==========
  /// Default locale
  static const String defaultLocale = 'fr';
  
  /// Supported locale codes
  static const List<String> supportedLocales = ['en', 'fr', 'ar'];
}

/// Sentry configuration constants
class SentryConfig {
  SentryConfig._();
  
  /// Sentry DSN
  static const String dsn = 'https://c2330142af6d1c0fcf8f2206cc345eb8@o4510465596325888.ingest.de.sentry.io/4510465604976720';
  
  /// Traces sample rate (1.0 = 100%)
  static const double tracesSampleRate = 1.0;
  
  /// Current environment
  static const String environment = 'production';
  
  /// Enable debug mode
  static const bool debugMode = false;
}
