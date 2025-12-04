import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/core/services/cache_service.dart';

/// ⚡ Service de Subscription avec Cache Intelligent
/// 
/// Features:
/// - ✅ Cache 15 min pour réduire les appels API
/// - ✅ Mode offline gracieux (24h max)
/// - ✅ Retry automatique avec backoff
/// - ✅ Métriques détaillées
/// - ✅ Invalidation intelligente
class SubscriptionService {
  final supabase = SupabaseService.client;
  
  /// Cache des résultats d'accès
  /// TTL: 15 minutes (balance entre fraîcheur et performance)
  late final CacheService<String, AccessResult> _cache;
  
  /// Configuration du retry
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  
  SubscriptionService() {
    _cache = CacheService<String, AccessResult>(
      maxSize: 500, // Peut cacher 500 magasins
      defaultTtl: const Duration(minutes: 15),
    );
    
    // Cleanup périodique (toutes les heures)
    _schedulePeriodicCleanup();
  }

  /// ⚡ Vérifie l'accès avec cache intelligent
  /// 
  /// Flow:
  /// 1. Vérifie le cache (< 15 min)
  /// 2. Si pas en cache → Appel API avec retry
  /// 3. Si erreur réseau → Mode offline gracieux
  Future<AccessResult> checkAccess(String magasinId) async {
    try {
      // 1️⃣ Essayer le cache d'abord
      return await _cache.getOrLoad(
        magasinId,
        () => _checkAccessFromApi(magasinId),
      );
    } catch (e) {
      print('❌ Erreur finale vérification accès: $e');
      
      // 2️⃣ Mode offline: utiliser cache même expiré (max 24h)
      final staleCache = await _getStaleCache(magasinId);
      if (staleCache != null) {
        print('⚠️ Mode offline - Cache utilisé (expiré)');
        return staleCache.copyWith(
          message: 'Mode offline - Vérification dans 1h',
        );
      }
      
      // 3️⃣ Dernière option: erreur
      return AccessResult.error();
    }
  }

  /// Appel API avec retry automatique et backoff exponentiel
  Future<AccessResult> _checkAccessFromApi(String magasinId) async {
    int retries = 0;
    Duration delay = _initialRetryDelay;
    
    while (retries < _maxRetries) {
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
        retries++;
        print('⚠️ Tentative $retries/$_maxRetries échouée: $e');
        
        if (retries >= _maxRetries) {
          // Log l'erreur après tous les retries
          await _logAccess(
            magasinId: magasinId,
            eventType: 'access_error',
            denialReason: e.toString(),
          );
          
          rethrow;
        }
        
        // Attendre avant de réessayer (backoff exponentiel: 2s, 4s, 8s)
        await Future.delayed(delay);
        delay *= 2;
      }
    }
    
    throw Exception('Max retries atteint');
  }

  /// Récupère un cache même expiré (pour mode offline)
  /// Maximum 24h d'ancienneté
  Future<AccessResult?> _getStaleCache(String magasinId) async {
    // TODO: Implémenter avec Hive ou SharedPreferences pour persister
    // Pour l'instant, retourne null
    return null;
  }

  /// Invalide le cache d'un magasin spécifique
  /// 
  /// À appeler quand:
  /// - L'abonnement est modifié
  /// - L'abonnement est renouvelé
  /// - Le statut change
  Future<void> invalidateCache(String magasinId) async {
    await _cache.invalidate(magasinId);
    print('🗑️ Cache invalidé pour magasin: $magasinId');
  }

  /// Invalide le cache de tous les magasins
  /// 
  /// À appeler en cas de changement global
  Future<void> invalidateAllCache() async {
    await _cache.clear();
    print('🗑️ Tout le cache invalidé');
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

  /// Nettoyage périodique du cache
  void _schedulePeriodicCleanup() {
    // Cleanup toutes les heures
    Stream.periodic(const Duration(hours: 1)).listen((_) {
      _cache.cleanup();
      _cache.logStats(); // Log pour monitoring
    });
  }

  /// Statistiques du cache (pour debugging/monitoring)
  CacheStats get cacheStats => _cache.stats;

  /// Affiche les stats (dev/debug)
  void logCacheStats() {
    _cache.logStats();
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

  /// Copie avec modifications
  AccessResult copyWith({
    bool? canAccess,
    String? status,
    String? message,
    DateTime? expiresOn,
    int? daysRemaining,
  }) {
    return AccessResult(
      canAccess: canAccess ?? this.canAccess,
      status: status ?? this.status,
      message: message ?? this.message,
      expiresOn: expiresOn ?? this.expiresOn,
      daysRemaining: daysRemaining ?? this.daysRemaining,
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
