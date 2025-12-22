/// Service de logging centralisé pour l'application.
///
/// Fournit une interface unifiée pour le logging avec:
/// - Niveaux de log (debug, info, warning, error)
/// - Formatage consistant
/// - Support pour Sentry en production
///
/// ### Exemple d'utilisation:
/// ```dart
/// AppLogger.info('User logged in');
/// AppLogger.error('Network error', e, stackTrace);
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Logger centralisé pour toute l'application.
///
/// Utilise [debugPrint] en mode debug et [Sentry] en production
/// pour les erreurs.
class AppLogger {
  // Private constructor - classe utilitaire
  AppLogger._();

  /// Couleurs ANSI pour terminal
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';

  /// Log niveau DEBUG - pour développement uniquement.
  ///
  /// [message] - Message à logger
  /// [tag] - Tag optionnel pour catégoriser le log
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      debugPrint('$_cyan🔍 DEBUG $prefix: $message$_reset');
    }
  }

  /// Log niveau INFO - informations générales.
  ///
  /// [message] - Message informatif
  /// [tag] - Tag optionnel
  static void info(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag]' : '';
    if (kDebugMode) {
      debugPrint('$_green✅ INFO $prefix: $message$_reset');
    }
    // Ajouter breadcrumb Sentry pour contexte
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: tag ?? 'app',
      level: SentryLevel.info,
    ));
  }

  /// Log niveau WARNING - alertes non-critiques.
  ///
  /// [message] - Description du warning
  /// [error] - Objet erreur optionnel
  /// [tag] - Tag optionnel
  static void warning(String message, {dynamic error, String? tag}) {
    final prefix = tag != null ? '[$tag]' : '';
    if (kDebugMode) {
      debugPrint('$_yellow⚠️ WARNING $prefix: $message$_reset');
      if (error != null) {
        debugPrint('$_yellow   Error: $error$_reset');
      }
    }
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: tag ?? 'app',
      level: SentryLevel.warning,
      data: error != null ? {'error': error.toString()} : null,
    ));
  }

  /// Log niveau ERROR - erreurs critiques.
  ///
  /// [message] - Description de l'erreur
  /// [error] - Exception ou erreur
  /// [stackTrace] - Stack trace optionnel
  /// [tag] - Tag optionnel
  ///
  /// En production, envoie automatiquement à Sentry.
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final prefix = tag != null ? '[$tag]' : '';

    if (kDebugMode) {
      debugPrint('$_red❌ ERROR  $prefix: $message$_reset');
      if (error != null) {
        debugPrint('$_red   Exception: $error$_reset');
      }
      if (stackTrace != null) {
        debugPrint('$_red   StackTrace: $stackTrace$_reset');
      }
    }

    // Envoyer à Sentry en production
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({'message': message}),
      );
    } else {
      Sentry.captureMessage(
        message,
        level: SentryLevel.error,
      );
    }
  }

  /// Log pour les opérations réseau/API.
  ///
  /// [method] - Méthode HTTP (GET, POST, etc.)
  /// [url] - URL de l'endpoint
  /// [statusCode] - Code de statut HTTP
  /// [duration] - Durée de la requête en ms
  static void network(
    String method,
    String url, {
    int? statusCode,
    int? duration,
  }) {
    if (kDebugMode) {
      final status = statusCode != null ? '[$statusCode]' : '';
      final time = duration != null ? '(${duration}ms)' : '';
      debugPrint('$_blue🌐 NETWORK: $method $url $status $time$_reset');
    }
  }

  /// Log pour les événements utilisateur (analytics).
  ///
  /// [event] - Nom de l'événement
  /// [properties] - Propriétés additionnelles
  static void event(String event, {Map<String, dynamic>? properties}) {
    if (kDebugMode) {
      debugPrint('$_cyan📊 EVENT: $event$_reset');
      if (properties != null) {
        debugPrint('$_cyan   Properties: $properties$_reset');
      }
    }
    Sentry.addBreadcrumb(Breadcrumb(
      message: event,
      category: 'user_event',
      level: SentryLevel.info,
      data: properties,
    ));
  }

  /// Log pour le lifecycle de l'app.
  ///
  /// [phase] - Phase du lifecycle (init, resume, pause, etc.)
  static void lifecycle(String phase) {
    if (kDebugMode) {
      debugPrint('$_green🔄 LIFECYCLE: $phase$_reset');
    }
    Sentry.addBreadcrumb(Breadcrumb(
      message: 'App $phase',
      category: 'lifecycle',
      level: SentryLevel.info,
    ));
  }
}
