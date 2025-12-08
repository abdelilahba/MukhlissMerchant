/// Service pour la gestion des opérations liées au magasin.
///
/// Fournit des méthodes utilitaires pour récupérer les informations
/// du magasin de l'utilisateur connecté.
library;

import 'package:mukhlissmagasin/core/config/app_config.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';

/// Service pour les opérations liées au magasin.
///
/// Centralise la logique de récupération du magasin
/// pour éviter la duplication de code.
class MagasinService {
  // Private constructor - classe utilitaire
  MagasinService._();

  /// Récupère l'ID du magasin de l'utilisateur connecté.
  ///
  /// Returns: ID du magasin ou null si:
  /// - Aucun utilisateur connecté
  /// - Aucun magasin associé à l'utilisateur
  /// - Erreur de communication avec Supabase
  ///
  /// ### Exemple:
  /// ```dart
  /// final magasinId = await MagasinService.getCurrentMagasinId();
  /// if (magasinId != null) {
  ///   // Utilisateur a un magasin
  /// } else {
  ///   // Rediriger vers login
  /// }
  /// ```
  static Future<String?> getCurrentMagasinId() async {
    try {
      final user = SupabaseService.client.auth.currentUser;

      if (user == null) {
        AppLogger.warning(
          'Aucun utilisateur connecté',
          tag: 'MagasinService',
        );
        return null;
      }

      AppLogger.debug(
        'Recherche magasin pour user: ${user.email}',
        tag: 'MagasinService',
      );

      // Récupérer le magasin associé à cet utilisateur
      final response = await SupabaseService.client
          .from(AppStrings.tableMagasins)
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        AppLogger.warning(
          'Aucun magasin trouvé pour l\'utilisateur ${user.email}',
          tag: 'MagasinService',
        );
        return null;
      }

      final magasinId = response['id'] as String;

      AppLogger.info(
        'Magasin ID récupéré: $magasinId',
        tag: 'MagasinService',
      );

      return magasinId;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur récupération magasin',
        error: e,
        stackTrace: stackTrace,
        tag: 'MagasinService',
      );
      return null;
    }
  }

  /// Vérifie si l'utilisateur courant a un magasin associé.
  ///
  /// Returns: true si un magasin existe, false sinon.
  static Future<bool> hasCurrentMagasin() async {
    final magasinId = await getCurrentMagasinId();
    return magasinId != null;
  }

  /// Récupère les informations complètes du magasin courant.
  ///
  /// Returns: Map contenant les données du magasin ou null.
  static Future<Map<String, dynamic>?> getCurrentMagasinInfo() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseService.client
          .from(AppStrings.tableMagasins)
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur récupération info magasin',
        error: e,
        stackTrace: stackTrace,
        tag: 'MagasinService',
      );
      return null;
    }
  }
}
