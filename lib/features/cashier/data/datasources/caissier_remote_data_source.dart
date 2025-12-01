import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';

import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

import '../../../profile/domain/entities/magasin_entity.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

class CaissierRemoteDataSource {
  final supabase = SupabaseService.client;
  
  // ✅ Cache en mémoire avec TTL et limite de taille
  final Map<String, CacheEntry<double>> _soldeCache = {};
  final Map<String, CacheEntry<int>> _pointsCache = {};
  final Map<String, CacheEntry<List<Reward>>> _rewardsCache = {};
  final Map<String, CacheEntry<ClientMagasinEntity>> _clientMagasinCache = {};
  
  // Limites de taille pour éviter memory leaks
  static const int _maxCacheSize = 5000;
  
  // Configuration du cache
  static const Duration _soldeCacheTTL = Duration(minutes: 5);
  static const Duration _pointsCacheTTL = Duration(minutes: 5);
  static const Duration _rewardsCacheTTL = Duration(minutes: 15);
  static const Duration _clientMagasinCacheTTL = Duration(minutes: 2);

  /// ✅ Nettoie le cache si trop grand
  void _cleanupCacheIfNeeded(Map cache) {
    if (cache.length > _maxCacheSize) {
      // Garder seulement les entrées non expirées
      cache.removeWhere((key, value) => value.isExpired);
      
      // Si toujours trop grand, supprimer les plus anciennes
      if (cache.length > _maxCacheSize) {
        final entries = cache.entries.toList()
          ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
        final toRemove = entries.take(cache.length - _maxCacheSize);
        for (var entry in toRemove) {
          cache.remove(entry.key);
        }
      }
    }
  }

  String _getSoldeKey(String clientId, String magasinId) => 'solde_${clientId}_$magasinId';
  String _getPointsKey(String clientId, String magasinId) => 'points_${clientId}_$magasinId';
  String _getRewardsKey(String clientId, String magasinId) => 'rewards_${clientId}_$magasinId';
  String _getClientMagasinKey(String clientId, String magasinId) => 'client_magasin_${clientId}_$magasinId';

  Future<double> getClientSolde({
    required String clientId,
    required String magasinId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getSoldeKey(clientId, magasinId);
    
    // Vérifier le cache si pas de refresh forcé
    if (!forceRefresh && _soldeCache.containsKey(cacheKey)) {
      final entry = _soldeCache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data;
      }
    }

    try {
      final response = await supabase
          .from('clientmagasin')
          .select('solde')
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId)
          .maybeSingle();

      final solde = response != null 
          ? (response['solde'] as num?)?.toDouble() ?? 0.0
          : 0.0;

      // Mettre en cache
      _soldeCache[cacheKey] = CacheEntry(
        data: solde,
        timestamp: DateTime.now(),
        ttl: _soldeCacheTTL,
      );
      _cleanupCacheIfNeeded(_soldeCache);

      return solde;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du solde: ${e.toString()}',
      );
    }
  }

Future<Client> getClientByCodeUnique({
    required int uniqueCode,
  }) async {
    try {
      print("Fetching client by unique code: $uniqueCode");
      final response = await supabase
          .from('clients')
          .select()
          .eq('code_unique', uniqueCode)
          .single();
       print('Fetched client data: $response');
      return Client.fromJson(response);
    } catch (e) {
       print('ERROR in getClientByCodeUnique: $e'); 
      throw Exception(
        'Erreur lors de la récupération du client par code unique: ${e.toString()}',
      );
    }
  }

  Future<int> getClientPoints({
    required String clientId,
    required String magasinId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getPointsKey(clientId, magasinId);
    
    // Vérifier le cache si pas de refresh forcé
    if (!forceRefresh && _pointsCache.containsKey(cacheKey)) {
      final entry = _pointsCache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data;
      }
    }

    try {
      final response = await supabase
          .from('clientmagasin')
          .select('cumulpoint')
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId)
          .maybeSingle();

      final points = response != null 
          ? (response['cumulpoint'] as int?) ?? 0
          : 0;

      // Mettre en cache
      _pointsCache[cacheKey] = CacheEntry(
        data: points,
        timestamp: DateTime.now(),
        ttl: _pointsCacheTTL,
      );
      _cleanupCacheIfNeeded(_pointsCache);

      return points;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des points: ${e.toString()}',
      );
    }
  }

  Future<List<Reward>> getAvailableRewards({
    required String clientId,
    required String magasinId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getRewardsKey(clientId, magasinId);
    
    // Vérifier le cache si pas de refresh forcé
    if (!forceRefresh && _rewardsCache.containsKey(cacheKey)) {
      final entry = _rewardsCache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data;
      }
    }

    try {
      // Get client points (utilise le cache)
      final clientPoints = await getClientPoints(
        clientId: clientId,
        magasinId: magasinId,
        forceRefresh: forceRefresh,
      );

      // Get all rewards for shop where client has enough points
      final response = await supabase
          .from('rewards')
          .select()
          .eq('magasin_id', magasinId)
          .lte('points_required', clientPoints)
          .order('points_required', ascending: true);

      final rewards = response.map((json) => Reward.fromJson(json)).toList();

      // Mettre en cache
      _rewardsCache[cacheKey] = CacheEntry(
        data: rewards,
        timestamp: DateTime.now(),
        ttl: _rewardsCacheTTL,
      );
      _cleanupCacheIfNeeded(_rewardsCache);

      return rewards;
    } catch (e) {
      throw Exception(
        'Erreur lors du chargement des récompenses: ${e.toString()}',
      );
    }
  }

  /// ✅ VERSION AMÉLIORÉE : Utilise une RPC atomique pour éviter les race conditions
  /// Cette méthode garantit que plusieurs utilisateurs peuvent réclamer des récompenses
  /// simultanément sans conflits grâce à une transaction atomique côté PostgreSQL
  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    try {
      print('🎁 Réclamation de récompense - Client: $clientId, Points requis: $pointsRequired');
      
      // ✅ Utiliser une fonction RPC PostgreSQL pour garantir l'atomicité
      // Cette fonction fait tout en une seule transaction :
      // - Vérifier les points disponibles
      // - Déduire les points
      // - Enregistrer la réclamation
      final result = await supabase.rpc(
        'claim_reward_atomic',
        params: {
          'p_client_id': clientId,
          'p_magasin_id': magasinId,
          'p_reward_id': rewardId,
          'p_points_required': pointsRequired,
        },
      );
      
      // Le résultat de la RPC est un booléen ou un objet avec status
      if (result == null || result == false) {
        throw Exception('Échec de la réclamation - points insuffisants ou erreur');
      }
      
      print('✅ Récompense réclamée avec succès');
      
      // Invalider les caches liés à ce client APRÈS le succès
      _invalidateClientCache(clientId, magasinId);
      
    } catch (e) {
      print('❌ Erreur lors de la réclamation de la récompense: ${e.toString()}');
      
      // Messages d'erreur plus clairs
      if (e.toString().contains('insufficient_points')) {
        throw Exception('Points insuffisants pour réclamer cette récompense');
      } else if (e.toString().contains('client_not_found')) {
        throw Exception('Client non trouvé');
      } else {
        throw Exception('Erreur lors de la réclamation: ${e.toString()}');
      }
    }
  }

  Future<ClientMagasinEntity> ajouterSoldeUniqueColdeAppliquerOffres({
    required int uniqueCode,
    required String magasinId,
    required double montant,
  }) async {
    try {
       print("===============================================================");
      final client = await getClientByCodeUnique(uniqueCode: uniqueCode);
      final clientId = client.id;
      print("------------------- Retrieved clientId: $clientId ------------------");
      final result = await supabase
         .rpc(
            'apply_offers_auto',
            params: {
              'p_client_id': clientId,
              'p_magasin_id': magasinId,
              'p_montant': montant,
            },
          )
        .single()
        .then(ClientMagasinEntity.fromJson);
        print('result after adding balance and applying offers: $result');
      print('=============================== clientId solde: $clientId ============================= $montant');
      // Invalider les autres caches car les données ont changé

      _invalidateClientCache(clientId, magasinId);

      return result;
    } catch (e) {
      print('ERROR in ajouterSoldeUniqueColdeAppliquerOffres: $e');
      throw Exception(
        'Erreur lors de l\'ajout du solde avec code unique et application des offres: ${e.toString()}',
      );
    }
  }

  Future<ClientMagasinEntity> ajouterSoldeEtAppliquerOffres({
    required String clientId,
    required String magasinId,
    required double montant,
    bool useCache = true,
  }) async {
    final cacheKey = _getClientMagasinKey(clientId, magasinId);
    
    try {
      // Toujours exécuter la fonction car elle modifie les données
      final result = await supabase
          .rpc(
            'apply_offers_auto',
            params: {
              'p_client_id': clientId,
              'p_magasin_id': magasinId,
              'p_montant': montant,
            },
          )
          .single()
          .then(ClientMagasinEntity.fromJson);

      // Mettre en cache le résultat
      if (useCache) {
        _clientMagasinCache[cacheKey] = CacheEntry(
          data: result,
          timestamp: DateTime.now(),
          ttl: _clientMagasinCacheTTL,
        );
      }

      // Invalider les autres caches car les données ont changé
      _invalidateClientCache(clientId, magasinId);

      return result;
    } catch (e) {
      throw Exception(
        'Erreur lors de l\'ajout du solde et application des offres: ${e.toString()}',
      );
    }
  }

  // Méthode pour invalider tous les caches d'un client
  void _invalidateClientCache(String clientId, String magasinId) {
    _soldeCache.remove(_getSoldeKey(clientId, magasinId));
    _pointsCache.remove(_getPointsKey(clientId, magasinId));
    _rewardsCache.remove(_getRewardsKey(clientId, magasinId));
    _clientMagasinCache.remove(_getClientMagasinKey(clientId, magasinId));
  }

  // Méthode pour nettoyer le cache expiré
  void cleanExpiredCache() {
    _soldeCache.removeWhere((key, entry) => entry.isExpired);
    _pointsCache.removeWhere((key, entry) => entry.isExpired);
    _rewardsCache.removeWhere((key, entry) => entry.isExpired);
    _clientMagasinCache.removeWhere((key, entry) => entry.isExpired);
  }

  // Méthode pour vider tout le cache
  void clearAllCache() {
    _soldeCache.clear();
    _pointsCache.clear();
    _rewardsCache.clear();
    _clientMagasinCache.clear();
  }

  // Méthode pour pré-charger les données d'un client
  Future<void> preloadClientData({
    required String clientId,
    required String magasinId,
  }) async {
    try {
      // Charger toutes les données en parallèle
      await Future.wait([
        getClientSolde(clientId: clientId, magasinId: magasinId),
        getClientPoints(clientId: clientId, magasinId: magasinId),
        getAvailableRewards(clientId: clientId, magasinId: magasinId),
      ]);
    } catch (e) {
      // Ignorer les erreurs de pré-chargement
      print('Erreur lors du pré-chargement: $e');
    }
  }

Future<MagasinModel> currentMagazin() async {
  // Récupère l'utilisateur connecté
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception('Aucun utilisateur connecté');
  }
  
  // Utilise l'ID de l'utilisateur pour récupérer le magasin
  final response = await supabase
      .from('magasins')
      .select()
      .eq('id', user.id)  // Supposons que vous avez une colonne user_id
      .single();
  
  return MagasinModel.fromJson(response);
}

// ================================================================================
// 🔧 GESTION DU CACHE - Méthodes d'invalidation
// ================================================================================

/// ✅ Invalide le cache pour un client spécifique
/// 
/// À appeler après toute modification de solde, points ou récompenses
/// pour garantir que les données affichées sont à jour.
/// 
/// Exemple d'utilisation :
/// ```dart
/// await claimReward(...);
/// invalidateCache(clientId: '...', magasinId: '...');
/// ```
void invalidateCache({
  required String clientId,
  required String magasinId,
}) {
  final soldeKey = _getSoldeKey(clientId, magasinId);
  final pointsKey = _getPointsKey(clientId, magasinId);
  final rewardsKey = _getRewardsKey(clientId, magasinId);
  final clientMagasinKey = _getClientMagasinKey(clientId, magasinId);
  
  _soldeCache.remove(soldeKey);
  _pointsCache.remove(pointsKey);
  _rewardsCache.remove(rewardsKey);
  _clientMagasinCache.remove(clientMagasinKey);
  
  print('✅ Cache invalidé pour client $clientId dans magasin $magasinId');
}

/// Invalide TOUT le cache
/// 
/// À utiliser en cas de problème ou lors de la déconnexion.
/// Force le rechargement de toutes les données depuis la DB.
void invalidateAllCache() {
  _soldeCache.clear();
  _pointsCache.clear();
  _rewardsCache.clear();
  _clientMagasinCache.clear();
  
  print('✅ Tout le cache a été invalidé');
}
}