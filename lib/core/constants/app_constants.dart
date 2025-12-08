/// Constantes de l'application centralisées
///
/// Ce fichier regroupe toutes les constantes magiques pour:
/// - Maintenance facile (change une fois, impact partout)
/// - Lisibilité (noms explicites vs nombres)
/// - Cohérence (mêmes valeurs partout)
///
/// ### Organisation:
/// - App Info
/// - Business Rules
/// - UI Configuration
/// - Network & API
/// - Cache & Performance
/// - Validation Rules
class AppConstants {
  // Private constructor pour empêcher instantiation
  AppConstants._();

  // ============================================
  // APP INFO
  // ============================================

  /// Nom de l'application
  static const String appName = 'Mukhliss Merchant';

  /// Version actuelle (sync avec pubspec.yaml)
  static const String appVersion = '1.0.0';

  /// Build number
  static const int buildNumber = 1;

  /// Package name
  static const String packageName = 'com.mukhliss.merchant';

  // ============================================
  // BUSINESS RULES - LOYALTY SYSTEM
  // ============================================

  /// Conversion: 10 MAD = 1 point de fidélité
  /// Exemple: 100 MAD dépensés = 10 points
  static const double pointsPerMAD = 0.1;

  /// Montant minimum pour une transaction
  /// En dessous de ce montant, transaction refusée
  static const double minTransactionAmount = 1.0;

  /// Montant maximum par transaction (sécurité)
  static const double maxTransactionAmount = 10000.0;

  /// Nombre maximum de récompenses par transaction
  static const int maxRewardsPerTransaction = 5;

  /// Points minimum requis pour échanger récompense
  static const int minPointsForReward = 10;

  /// Durée de validité des points (jours)
  /// null = illimité
  static const int? pointsExpirationDays = 365;

  // ============================================
  // VALIDATION RULES
  // ============================================

  /// Longueur minimum mot de passe
  static const int minPasswordLength = 8;

  /// Longueur maximum mot de passe
  static const int maxPasswordLength = 128;

  /// Longueur code QR unique
  static const int qrCodeLength = 8;

  /// Pattern email valide (regex)
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  /// Pattern téléphone (Maroc)
  static const String phonePattern = r'^(\+212|0)([ \-_/]*)(\d[ \-_/]*){9}$';

  // ============================================
  // CACHE & PERFORMANCE
  // ============================================

  /// Durée de vie cache par défaut
  static const Duration cacheExpiration = Duration(minutes: 15);

  /// Taille maximum du cache (nombre d'entrées)
  static const int maxCacheSize = 100;

  /// Timeout pour requêtes réseau
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Timeout pour requêtes longues (upload)
  static const Duration longNetworkTimeout = Duration(minutes: 2);

  /// Nombre de retry en cas d'échec réseau
  static const int maxNetworkRetries = 3;

  /// Délai entre retries (exponential backoff)
  static const Duration retryDelay = Duration(seconds: 2);

  // ============================================
  // UI CONFIGURATION
  // ============================================

  /// Durée animation par défaut
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Durée animation rapide
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Durée animation lente
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// Padding par défaut
  static const double defaultPadding = 16.0;

  /// Padding petit
  static const double smallPadding = 8.0;

  /// Padding large
  static const double largePadding = 24.0;

  /// Border radius par défaut
  static const double defaultRadius = 8.0;

  /// Border radius boutons
  static const double buttonRadius = 12.0;

  /// Border radius cards
  static const double cardRadius = 16.0;

  /// Elevation cards
  static const double cardElevation = 2.0;

  /// Taille icône par défaut
  static const double defaultIconSize = 24.0;

  /// Taille icône petite
  static const double smallIconSize = 16.0;

  /// Taille icône grande
  static const double largeIconSize = 32.0;

  // ============================================
  // TEXT SIZES
  // ============================================

  /// Taille texte titre
  static const double titleTextSize = 24.0;

  /// Taille texte sous-titre
  static const double subtitleTextSize = 18.0;

  /// Taille texte body
  static const double bodyTextSize = 16.0;

  /// Taille texte caption
  static const double captionTextSize = 14.0;

  /// Taille texte petit
  static const double smallTextSize = 12.0;

  // ============================================
  // SNACKBAR & DIALOGS
  // ============================================

  /// Durée affichage snackbar succès
  static const Duration snackbarSuccessDuration = Duration(seconds: 2);

  /// Durée affichage snackbar erreur
  static const Duration snackbarErrorDuration = Duration(seconds: 4);

  /// Durée affichage snackbar info
  static const Duration snackbarInfoDuration = Duration(seconds: 3);

  // ============================================
  // PAGINATION
  // ============================================

  /// Nombre d'items par page (liste transactions)
  static const int itemsPerPage = 20;

  /// Nombre d'items dans recherche
  static const int searchItemsLimit = 50;

  // ============================================
  // IMAGE & MEDIA
  // ============================================

  /// Qualité compression images (0-100)
  static const int imageQuality = 85;

  /// Taille maximum image upload (bytes)
  /// 5 MB
  static const int maxImageSize = 5 * 1024 * 1024;

  /// Format image par défaut
  static const String imageFormat = 'jpg';

  // ============================================
  // DATES & TIMES
  // ============================================

  /// Format date par défaut (dd/MM/yyyy)
  static const String dateFormat = 'dd/MM/yyyy';

  /// Format date avec heure (dd/MM/yyyy HH:mm)
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  /// Format heure (HH:mm)
  static const String timeFormat = 'HH:mm';

  // ============================================
  // STORAGE KEYS (SharedPreferences)
  // ============================================

  /// Clé pour token auth
  static const String authTokenKey = 'auth_token';

  /// Clé pour user ID
  static const String userIdKey = 'user_id';

  /// Clé pour langue sélectionnée
  static const String languageKey = 'selected_language';

  /// Clé pour thème (dark/light)
  static const String themeKey = 'theme_mode';

  /// Clé pour première ouverture app
  static const String firstLaunchKey = 'first_launch';

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Activer notifications push
  static const bool enablePushNotifications = false;

  /// Activer mode offline
  static const bool enableOfflineMode = false;

  /// Activer analytics
  static const bool enableAnalytics = true;

  /// Activer crash reporting (Sentry)
  static const bool enableCrashReporting = true;

  /// Mode debug (logs verbeux)
  static bool get isDebugMode {
    return !const bool.fromEnvironment('dart.vm.product');
  }
}
