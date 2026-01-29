/// Configuration centralisée de l'application.
///
/// Contient toutes les constantes et configurations
/// pour éviter les valeurs hardcodées dispersées.
library;

import 'package:flutter/foundation.dart';

/// Configuration principale de l'application.
///
/// Utilise [kDebugMode] pour différencier dev/prod.
class AppConfig {
  // Private constructor - classe utilitaire
  AppConfig._();

  // ═══════════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════════

  /// Nom de l'application
  static const String appName = 'Mukhliss Merchant';

  /// Version de l'application (doit matcher pubspec.yaml)
  static const String appVersion = '1.0.0';

  /// Build number
  static const int buildNumber = 1;

  /// Release name pour Sentry
  static String get sentryRelease => '$appName@$appVersion';

  // ═══════════════════════════════════════════════════════════════
  // SENTRY CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// DSN Sentry pour monitoring erreurs
  static const String sentryDsn =
      'https://c2330142af6d1c0fcf8f2206cc345eb8@o4510465596325888.ingest.de.sentry.io/4510465604976720';

  /// Environnement (production/development)
  static String get environment => kDebugMode ? 'development' : 'production';

  /// Taux d'échantillonnage traces (1.0 = 100%)
  static double get tracesSampleRate => kDebugMode ? 1.0 : 0.2;

  /// Mode debug Sentry (désactivé en production)
  static bool get sentryDebug => kDebugMode;

  // ═══════════════════════════════════════════════════════════════
  // BUSINESS RULES
  // ═══════════════════════════════════════════════════════════════

  /// Points gagnés par MAD dépensé (10 MAD = 1 point)
  static const double pointsPerMAD = 0.1;

  /// Montant minimum pour une transaction (en MAD)
  static const double minTransactionAmount = 1.0;

  /// Nombre maximum de récompenses par transaction
  static const int maxRewardsPerTransaction = 5;

  // ═══════════════════════════════════════════════════════════════
  // CACHE CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Durée d'expiration cache par défaut
  static const Duration cacheExpiration = Duration(minutes: 15);

  /// Taille maximale du cache LRU
  static const int maxCacheSize = 100;

  // ═══════════════════════════════════════════════════════════════
  // UI CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Durée des animations
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Padding par défaut
  static const double defaultPadding = 16.0;

  /// Border radius par défaut
  static const double defaultRadius = 8.0;

  /// Durée affichage SnackBar
  static const Duration snackBarDuration = Duration(seconds: 3);

  // ═══════════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Timeout pour les requêtes API
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Nombre de tentatives en cas d'échec
  static const int maxRetries = 3;

  /// Délai entre les tentatives
  static const Duration retryDelay = Duration(seconds: 2);

  // ═══════════════════════════════════════════════════════════════
  // SUBSCRIPTION CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Intervalle de vérification abonnement
  static const Duration subscriptionCheckInterval = Duration(minutes: 5);

  /// Jours avant expiration pour avertissement
  static const int subscriptionWarningDays = 7;
}

/// Couleurs de l'application.
///
/// Définit la palette de couleurs utilisée dans tout l'app.
class AppColors {
  AppColors._();

  // Brand Colors (à personnaliser selon votre charte)
  static const int primaryValue = 0xFF2196F3;
  static const int secondaryValue = 0xFFFFC107;
  static const int accentValue = 0xFF4CAF50;

  // Status Colors
  static const int successValue = 0xFF4CAF50;
  static const int warningValue = 0xFFFFC107;
  static const int errorValue = 0xFFF44336;
  static const int infoValue = 0xFF2196F3;

  // Neutral Colors
  static const int backgroundValue = 0xFFF5F5F5;
  static const int surfaceValue = 0xFFFFFFFF;
  static const int textPrimaryValue = 0xFF212121;
  static const int textSecondaryValue = 0xFF757575;
}

/// Strings constantes de l'application.
///
/// Pour les textes non-localisés ou les clés.
class AppStrings {
  AppStrings._();

  // Tables Supabase
  static const String tableMagasins = 'magasins';
  static const String tableClients = 'clients';
  static const String tableRewards = 'rewards';
  static const String tableOffers = 'offers';
  static const String tableTransactions = 'transactions';

  // Routes
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeOffers = '/offers';
  static const String routeRewards = '/rewards';
  static const String routeCaissiers = '/caissiers';
  static const String routeProfile = '/profile';

  // SharedPreferences Keys
  static const String prefLocale = 'app_locale';
  static const String prefTheme = 'app_theme';
  static const String prefFirstLaunch = 'first_launch';
}
