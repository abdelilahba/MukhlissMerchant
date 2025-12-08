/// Point d'entrée principal de l'application Mukhliss Merchant.
///
/// Configure et lance l'application avec:
/// - Initialisation Sentry (monitoring erreurs)
/// - Injection de dépendances
/// - BlocProviders globaux
///
/// L'application suit Clean Architecture avec:
/// - Domain Layer: Entités et UseCases
/// - Data Layer: Repositories et DataSources
/// - Presentation Layer: Cubits et Screens
///
/// @author Mukhliss Team
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Core imports
import 'package:mukhlissmagasin/core/config/app_config.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/core/providers/app_bloc_providers.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';

// App Widget
import 'package:mukhlissmagasin/app.dart';

/// Point d'entrée de l'application.
///
/// Initialise dans l'ordre:
/// 1. Flutter bindings
/// 2. Sentry (monitoring)
/// 3. Dependency injection
/// 4. App widget avec BlocProviders
void main() async {
  // Assure l'initialisation des bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Sentry pour monitoring erreurs
  await _initializeSentry();
}

/// Configure et initialise Sentry pour le monitoring.
///
/// Sentry capture:
/// - Erreurs non gérées
/// - Performance traces
/// - Breadcrumbs contextuels
Future<void> _initializeSentry() async {
  await SentryFlutter.init(
    (options) {
      // ═══════════════════════════════════════════════════
      // CONFIGURATION SENTRY
      // ═══════════════════════════════════════════════════

      // DSN depuis configuration centralisée
      options.dsn = AppConfig.sentryDsn;

      // Taux d'échantillonnage (100% en dev, 20% en prod)
      options.tracesSampleRate = AppConfig.tracesSampleRate;

      // Environnement (development/production)
      options.environment = AppConfig.environment;

      // Activer auto performance tracing
      options.enableAutoPerformanceTracing = true;

      // Mode debug (uniquement en développement)
      options.debug = AppConfig.sentryDebug;

      // Release name pour identifier la version
      options.release = AppConfig.sentryRelease;
    },
    appRunner: () async {
      // ═══════════════════════════════════════════════════
      // INITIALISATION APPLICATION
      // ═══════════════════════════════════════════════════

      AppLogger.lifecycle('Initializing app...');

      // Initialiser injection de dépendances
      await initDependencies();
      AppLogger.info('Dependencies initialized', tag: 'Main');

      // Lancer l'application
      AppLogger.lifecycle('Starting app...');

      runApp(
        // Wrapper avec tous les BlocProviders
        AppBlocProviders.wrap(
          child: const MukhlissApp(),
        ),
      );

      AppLogger.lifecycle('App started');
    },
  );
}
