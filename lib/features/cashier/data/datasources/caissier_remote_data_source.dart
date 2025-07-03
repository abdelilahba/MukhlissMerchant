import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

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
  
  // Cache en mémoire avec TTL
  final Map<String, CacheEntry<double>> _soldeCache = {};
  final Map<String, CacheEntry<int>> _pointsCache = {};
  final Map<String, CacheEntry<List<Reward>>> _rewardsCache = {};
  final Map<String, CacheEntry<ClientMagasinEntity>> _clientMagasinCache = {};
  
  // Configuration du cache
  static const Duration _soldeCacheTTL = Duration(minutes: 5);
  static const Duration _pointsCacheTTL = Duration(minutes: 5);
  static const Duration _rewardsCacheTTL = Duration(minutes: 15);
  static const Duration _clientMagasinCacheTTL = Duration(minutes: 2);

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

      return solde;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du solde: ${e.toString()}',
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

      return rewards;
    } catch (e) {
      throw Exception(
        'Erreur lors du chargement des récompenses: ${e.toString()}',
      );
    }
  }

  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    try {
      // 1. Get current client points (utilise le cache)
      final currentPoints = await getClientPoints(
        clientId: clientId,
        magasinId: magasinId,
        forceRefresh: true, // Force refresh pour avoir les données les plus récentes
      );

      if (currentPoints < pointsRequired) {
        throw Exception('Points insuffisants');
      }

      // 2. Subtract points from client
      final newPoints = currentPoints - pointsRequired;
      await supabase
          .from('clientmagasin')
          .update({'cumulpoint': newPoints})
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId);

      // 3. Invalider les caches liés à ce client
      _invalidateClientCache(clientId, magasinId);

      // 4. Record the reward claim (commenté dans l'original)
      // await supabase.from('reward_claims').insert({
      //   'client_id': clientId,
      //   'magasin_id': magasinId,
      //   'reward_id': rewardId,
      //   'points_used': pointsRequired,
      //   'claimed_at': DateTime.now().toIso8601String(),
      //   'status': 'claimed',
      // });
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de la récompense: ${e.toString()}',
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
}