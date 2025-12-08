import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// App-wide logging utility that provides structured logging
/// and integrates with Sentry for error tracking.
/// 
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error occurred', error: e, stackTrace: stackTrace);
/// ```
class AppLogger {
  AppLogger._(); // Private constructor to prevent instantiation

  /// Log level for debug messages (only shown in debug mode)
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'Debug',
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log level for informational messages
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'Info',
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log level for warning messages
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'Warning',
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
    
    // Send warnings to Sentry as breadcrumbs
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        level: SentryLevel.warning,
        category: tag ?? 'warning',
      ),
    );
  }

  /// Log level for error messages (automatically sent to Sentry)
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'Error',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
    
    // Send errors to Sentry
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': message,
          'tag': tag ?? 'error',
        }),
      );
    } else {
      Sentry.captureMessage(
        message,
        level: SentryLevel.error,
      );
    }
  }

  /// Log level for fatal/critical errors (automatically sent to Sentry)
  static void fatal(
    String message, {
    String? tag,
    required Object error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'Fatal',
      level: 1200, // Fatal level
      error: error,
      stackTrace: stackTrace,
    );
    
    // Send fatal errors to Sentry with high priority
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'message': message,
        'tag': tag ?? 'fatal',
      }),
    );
  }
}
