// features/rewards/data/datasources/reward_remote_data_source.dart
import 'package:mukhlissmagasin/core/services/cache_entry.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardRemoteDataSource {
  final supabase = SupabaseService.client;
  static const String rewardsBucket = 'rewards';

  // ✅ Cache en mémoire avec TTL
  final Map<String, CacheEntry<List<Reward>>> _rewardsCache = {};
  final Map<String, CacheEntry<int?>> _categoryCache = {};
  final Map<int, CacheEntry<List<PresetImage>>> _presetImagesCache = {};

  // Configuration du cache
  static const Duration _rewardsCacheTTL = Duration(minutes: 5);
  static const Duration _categoryCacheTTL = Duration(minutes: 15);
  static const Duration _presetImagesCacheTTL = Duration(minutes: 30);
  static const int _maxCacheSize = 100;

  /// Récupère toutes les récompenses d'un magasin avec cache
  Future<List<Reward>> getRewardsByStore(String storeId, {bool forceRefresh = false}) async {
    // Vérifier le cache si pas de forceRefresh
    if (!forceRefresh) {
      final cached = _rewardsCache[storeId];
      if (cached != null && !cached.isExpired) {
        return cached.data;
      }
    }

    final response = await supabase
        .from('rewards')
        .select('*')
        .eq('magasin_id', storeId);

    final rewards = response.map((json) => Reward.fromJson(json)).toList();

    // Mettre en cache
    _cleanupCacheIfNeeded(_rewardsCache);
    _rewardsCache[storeId] = CacheEntry(
      data: rewards,
      timestamp: DateTime.now(),
      ttl: _rewardsCacheTTL,
    );

    return rewards;
  }

  /// Ajoute une nouvelle récompense et invalide le cache
  Future<void> addReward(Reward reward) async {
    try {
      await supabase.from('rewards').insert(reward.toJson());
      _invalidateRewardsCache(reward.shopId);
    } on PostgrestException catch (e) {
      throw Exception('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour une récompense existante et invalide le cache
  Future<void> updateReward(Reward reward) async {
    await supabase.from('rewards').update(reward.toJson()).eq('id', reward.id);
    _invalidateRewardsCache(reward.shopId);
  }

  /// Supprime une récompense et invalide le cache
  Future<void> deleteReward(String id) async {
    try {
      await SupabaseService.ensureValidSession();
      await supabase.from('rewards').delete().eq('id', id);
      // Invalider tout le cache car on ne connaît pas le storeId
      _rewardsCache.clear();
    } on PostgrestException catch (e) {
      // 23503: foreign_key_violation (récompense déjà réclamée par des clients)
      if (e.code == '23503' ||
          e.message.toLowerCase().contains('foreign key') ||
          e.message.toLowerCase().contains('reward_claims')) {
        // Désactivation automatique au lieu d'une suppression destructrice
        await supabase.from('rewards').update({'is_active': false}).eq('id', id);
        _rewardsCache.clear();
        return;
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Enregistre une réclamation de récompense
  Future<void> claimReward(String userId, String rewardId) async {
    await supabase.from('reward_claims').insert({
      'user_id': userId,
      'reward_id': rewardId,
      'claimed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère les images prédéfinies pour une catégorie donnée avec cache
  Future<List<PresetImage>> getPresetImages(int categoryId) async {
    // Vérifier le cache
    final cached = _presetImagesCache[categoryId];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final response = await supabase
        .from('reward_preset_images')
        .select('*')
        .or('category_id.eq.$categoryId,category_id.is.null')
        .order('sort_order', ascending: true);

    final images = response.map((json) => PresetImage.fromJson(json)).toList();

    // Mettre en cache
    _presetImagesCache[categoryId] = CacheEntry(
      data: images,
      timestamp: DateTime.now(),
      ttl: _presetImagesCacheTTL,
    );

    return images;
  }

  /// Récupère le category_id du magasin connecté avec cache
  Future<int?> getMagasinCategoryId(String magasinId) async {
    // Vérifier le cache
    final cached = _categoryCache[magasinId];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final response = await supabase
        .from('magasins')
        .select('Categorieid')
        .eq('id', magasinId)
        .maybeSingle();

    final categoryId = response == null ? null : response['Categorieid'] as int?;

    // Mettre en cache
    _categoryCache[magasinId] = CacheEntry(
      data: categoryId,
      timestamp: DateTime.now(),
      ttl: _categoryCacheTTL,
    );

    return categoryId;
  }

  /// Invalide le cache des récompenses pour un magasin
  void _invalidateRewardsCache(String storeId) {
    _rewardsCache.remove(storeId);
  }

  /// Nettoie le cache si trop grand (générique)
  void _cleanupCacheIfNeeded(Map cache) {
    if (cache.length > _maxCacheSize) {
      cache.removeWhere((_, value) => value.isExpired);
    }
  }

  /// Vide tout le cache (utile pour logout)
  void clearCache() {
    _rewardsCache.clear();
    _categoryCache.clear();
    _presetImagesCache.clear();
  }
}

/// Modèle simple pour les images prédéfinies
class PresetImage {
  final int id;
  final int? categoryId;
  final String imageUrl;
  final String? label;

  PresetImage({
    required this.id,
    this.categoryId,
    required this.imageUrl,
    this.label,
  });

  factory PresetImage.fromJson(Map<String, dynamic> json) => PresetImage(
    id: json['id'],
    categoryId: json['category_id'],
    imageUrl: json['image_url'],
    label: json['label'],
  );
}
