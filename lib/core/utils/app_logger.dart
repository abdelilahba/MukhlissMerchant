import 'package:logger/logger.dart';

/// Service de logging centralisé pour l'application
///
/// Remplace les print() statements et offre:
/// - Différents niveaux de log (debug, info, warning, error)
/// - Formatage automatique
/// - Stack traces pour errors
/// - Timestamps
/// - Couleurs en console
///
/// ### Usage:
/// ```dart
/// AppLogger.debug('Message de debug');
/// AppLogger.info('Information utilisateur');
/// AppLogger.warning('Attention: situation anormale');
/// AppLogger.error('Erreur critique', error, stackTrace);
/// ```
class AppLogger {
  // Private constructor pour empêcher instantiation
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Nombre de method calls à afficher
      errorMethodCount: 8, // Pour errors
      lineLength: 120, // Largeur des lignes
      colors: true, // Couleurs en console
      printEmojis: true, // Emojis pour identifier niveau
      printTime: true, // Timestamp
    ),
    level: _getLogLevel(), // Niveau selon environnement
  );

  /// Logger pour production (minimal, pas de debug)
  static final Logger _productionLogger = Logger(
    printer: SimplePrinter(
      printTime: true,
      colors: false,
    ),
    level: Level.warning, // Seulement warnings et errors en prod
  );

  /// Détermine le niveau de log selon environnement
  static Level _getLogLevel() {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? Level.warning : Level.debug;
  }

  /// Get logger approprié selon environnement
  static Logger get _currentLogger {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _productionLogger : _logger;
  }

  /// Log debug - Informations de développement
  ///
  /// Utilisé pour tracer le flow de l'application en développement.
  /// N'apparaît PAS en production.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.debug('Entering ajouterSolde method');
  /// AppLogger.debug('Client ID: $clientId, Montant: $montant');
  /// ```
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _currentLogger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info - Informations importantes
  ///
  /// Événements significatifs de l'application.
  /// Apparaît en développement et production.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.info('User logged in successfully');
  /// AppLogger.info('Solde ajouté: $montant MAD');
  /// ```
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _currentLogger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning - Situations anormales mais gérables
  ///
  /// Comportements inattendus qui ne bloquent pas l'app.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.warning('Cache miss, fetching from network');
  /// AppLogger.warning('Utilisateur tentative login échouée');
  /// ```
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _currentLogger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error - Erreurs critiques
  ///
  /// Erreurs qui nécessitent attention immédiate.
  /// Toujours loggé, même en production.
  ///
  /// ### Exemple:
  /// ```dart
  /// try {
  ///   await repository.fetch();
  /// } catch (e, stack) {
  ///   AppLogger.error('Failed to fetch data', e, stack);
  ///   rethrow;
  /// }
  /// ```
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _currentLogger.e(message, error: error, stackTrace: stackTrace);

    // TODO: Envoyer à Sentry en production
    // if (isProduction) {
    //   Sentry.captureException(error, stackTrace: stackTrace);
    // }
  }

  /// Log verbose - Détails très bas niveau
  ///
  /// Pour debugging très détaillé. Désactivé en production.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.verbose('HTTP request headers: $headers');
  /// ```
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _currentLogger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log pour lifecycle events
  ///
  /// Tracking des événements du cycle de vie de l'app.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.lifecycle('App resumed');
  /// AppLogger.lifecycle('Screen mounted: CaissierHomeScreen');
  /// ```
  static void lifecycle(String message) {
    _currentLogger.i('🔄 LIFECYCLE: $message');
  }

  /// Log pour network events
  ///
  /// Tracking des appels réseau.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.network('GET /api/clients - 200 OK');
  /// AppLogger.network('POST /api/transactions - 201 Created');
  /// ```
  static void network(String message) {
    _currentLogger.d('🌐 NETWORK: $message');
  }

  /// Log pour navigation events
  ///
  /// Tracking de la navigation utilisateur.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.navigation('Navigated to LoginScreen');
  /// AppLogger.navigation('Back to HomeScreen');
  /// ```
  static void navigation(String message) {
    _currentLogger.i('🧭 NAVIGATION: $message');
  }

  /// Log pour business logic events
  ///
  /// Événements métier importants.
  ///
  /// ### Exemple:
  /// ```dart
  /// AppLogger.business('Transaction completed: 100 MAD');
  /// AppLogger.business('Reward claimed: ${reward.name}');
  /// ```
  static void business(String message) {
    _currentLogger.i('💼 BUSINESS: $message');
  }
}
