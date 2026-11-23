// features/offers/data/datasources/offer_remote_data_source.dart
import 'package:mukhlissmagasin/core/services/cache_entry.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';

class OfferRemoteDataSource {
  final supabase = SupabaseService.client;

  // ✅ Cache en mémoire avec TTL
  final Map<String, CacheEntry<List<Offer>>> _offersCache = {};

  // Configuration du cache
  static const Duration _offersCacheTTL = Duration(minutes: 5);
  static const int _maxCacheSize = 100;

  /// Récupère les offres d'un magasin avec cache
  Future<List<Offer>> getOffersByStore(String storeId, {bool forceRefresh = false}) async {
    // Vérifier le cache si pas de forceRefresh
    if (!forceRefresh) {
      final cached = _offersCache[storeId];
      if (cached != null && !cached.isExpired) {
        return cached.data;
      }
    }

    // Requête Supabase
    final response = await supabase
        .from('offers')
        .select('*')
        .eq('magasin_id', storeId)
        .order('created_at', ascending: false);

    final offers = response.map((json) => Offer.fromJson(json)).toList();

    // Mettre en cache
    _cleanupCacheIfNeeded();
    _offersCache[storeId] = CacheEntry(
      data: offers,
      timestamp: DateTime.now(),
      ttl: _offersCacheTTL,
    );

    return offers;
  }

  /// Ajoute une offre et invalide le cache
  Future<void> addOffer(Offer offer) async {
    await supabase.from('offers').insert(offer.toJson());
    _invalidateCache(offer.magasinId);
  }

  /// Met à jour une offre et invalide le cache
  Future<void> updateOffer(Offer offer) async {
    await supabase.from('offers').update(offer.toJson()).eq('id', offer.id);
    _invalidateCache(offer.magasinId);
  }

  /// Supprime une offre et invalide le cache
  Future<void> deleteOffer(String id) async {
    await supabase.from('offers').delete().eq('id', id);
    // Invalider tout le cache car on ne connaît pas le storeId
    _offersCache.clear();
  }

  /// Invalide le cache pour un magasin spécifique
  void _invalidateCache(String storeId) {
    _offersCache.remove(storeId);
  }

  /// Nettoie le cache si trop grand
  void _cleanupCacheIfNeeded() {
    if (_offersCache.length > _maxCacheSize) {
      _offersCache.removeWhere((_, entry) => entry.isExpired);
      if (_offersCache.length > _maxCacheSize) {
        final entries = _offersCache.entries.toList()
          ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
        final toRemove = entries.take(_offersCache.length - _maxCacheSize);
        for (final entry in toRemove) {
          _offersCache.remove(entry.key);
        }
      }
    }
  }

  /// Vide tout le cache (utile pour logout)
  void clearCache() {
    _offersCache.clear();
  }
}
