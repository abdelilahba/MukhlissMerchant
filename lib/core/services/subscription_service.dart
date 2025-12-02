import 'package:mukhlissmagasin/core/services/supabase_service.dart';

/// Service pour gérer les abonnements et vérifier l'accès
class SubscriptionService {
  final supabase = SupabaseService.client;

  /// Vérifie si le magasin a accès à l'app
  /// Appelé au démarrage de l'application
  Future<AccessResult> checkAccess(String magasinId) async {
    try {
      // Appel de la fonction SQL
      final response = await supabase
          .rpc('check_app_access', params: {'p_magasin_id': magasinId})
          .single();

      final result = AccessResult.fromJson(response);

      // Log l'événement d'accès
      await _logAccess(
        magasinId: magasinId,
        eventType: result.canAccess ? 'access_granted' : 'access_denied',
        denialReason: result.canAccess ? null : result.message,
      );

      return result;
    } catch (e) {
      print('❌ Erreur vérification accès: $e');
      
      // Log l'erreur
      await _logAccess(
        magasinId: magasinId,
        eventType: 'access_error',
        denialReason: e.toString(),
      );
      
      return AccessResult.error();
    }
  }

  /// Log un événement d'accès
  Future<void> _logAccess({
    required String magasinId,
    required String eventType,
    String? denialReason,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      
      await supabase.from('app_access_logs').insert({
        'magasin_id': magasinId,
        'event_type': eventType,
        'user_id': user?.id,
        'user_email': user?.email,
        'denial_reason': denialReason,
        'app_version': '1.0.0', // TODO: Récupérer depuis package_info
      });
    } catch (e) {
      print('⚠️ Erreur log accès: $e');
      // Ne pas bloquer l'app si le log échoue
    }
  }

  /// Log l'ouverture de l'app
  Future<void> logAppOpened(String magasinId) async {
    await _logAccess(
      magasinId: magasinId,
      eventType: 'app_opened',
    );
  }
}

/// Résultat de la vérification d'accès
class AccessResult {
  final bool canAccess;
  final String status;
  final String message;
  final DateTime? expiresOn;
  final int? daysRemaining;

  AccessResult({
    required this.canAccess,
    required this.status,
    required this.message,
    this.expiresOn,
    this.daysRemaining,
  });

  factory AccessResult.fromJson(Map<String, dynamic> json) {
    return AccessResult(
      canAccess: json['can_access'] as bool,
      status: json['status'] as String,
      message: json['message'] as String,
      expiresOn: json['expires_on'] != null
          ? DateTime.parse(json['expires_on'])
          : null,
      daysRemaining: json['days_remaining'] as int?,
    );
  }

  factory AccessResult.error() {
    return AccessResult(
      canAccess: false,
      status: 'error',
      message: 'Erreur de connexion. Vérifiez votre connexion internet et réessayez.',
    );
  }

  /// Est-ce qu'on doit afficher un avertissement ?
  bool get shouldShowWarning =>
      canAccess &&
      status == 'expiring_soon' &&
      daysRemaining != null &&
      daysRemaining! <= 7;

  /// Titre pour l'écran de blocage
  String get blockTitle {
    switch (status) {
      case 'expired':
        return 'Abonnement Expiré';
      case 'suspended':
        return 'Compte Suspendu';
      case 'no_subscription':
        return 'Aucun Abonnement';
      case 'inactive':
        return 'Compte Désactivé';
      case 'error':
        return 'Erreur de Connexion';
      default:
        return 'Accès Refusé';
    }
  }

  /// Icône pour l'écran de blocage
  String get blockIcon {
    switch (status) {
      case 'expired':
        return '⏰';
      case 'suspended':
        return '🚫';  
      case 'no_subscription':
        return '📋';
      case 'inactive':
        return '🔒';
      case 'error':
        return '⚠️';
      default:
        return '❌';
    }
  }
}
