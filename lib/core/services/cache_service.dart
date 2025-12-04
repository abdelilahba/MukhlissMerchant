import 'dart:async';
import 'dart:collection';

/// 🚀 Service de Cache Professionnel
/// 
/// Features:
/// - ✅ TTL (Time To Live) configurable
/// - ✅ LRU (Least Recently Used) eviction
/// - ✅ Thread-safe operations
/// - ✅ Métriques (hits/misses)
/// - ✅ Invalidation sélective ou totale
/// - ✅ Memory-efficient
/// 
/// Usage:
/// ```dart
/// final cache = CacheService<String, UserData>(
///   maxSize: 100,
///   defaultTtl: Duration(minutes: 15),
/// );
/// 
/// await cache.set('user_123', userData);
/// final user = await cache.get('user_123');
/// ```
class CacheService<K, V> {
  /// Configuration
  final int maxSize;
  final Duration defaultTtl;
  
  /// Storage interne (LRU Map)
  late final _LruMap<K, _CachedEntry<V>> _cache;
  
  /// Métriques
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;
  
  CacheService({
    this.maxSize = 100,
    this.defaultTtl = const Duration(minutes: 15),
  }) {
    _cache = _LruMap<K, _CachedEntry<V>>(maxSize);
  }

  /// Récupère une valeur du cache
  /// 
  /// Returns null si:
  /// - La clé n'existe pas
  /// - L'entrée est expirée
  Future<V?> get(K key) async {
    final entry = _cache[key];
    
    // Pas en cache
    if (entry == null) {
      _misses++;
      return null;
    }
    
    // Expiré
    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      _evictions++;
      return null;
    }
    
    // Cache hit! 🎯
    _hits++;
    entry.updateAccessTime(); // Pour LRU
    return entry.value;
  }

  /// Stocke une valeur dans le cache
  /// 
  /// [ttl] peut override le TTL par défaut
  Future<void> set(K key, V value, {Duration? ttl}) async {
    final effectiveTtl = ttl ?? defaultTtl;
    
    _cache[key] = _CachedEntry(
      value: value,
      expiresAt: DateTime.now().add(effectiveTtl),
    );
  }

  /// Récupère avec fallback automatique
  /// 
  /// Si la valeur n'est pas en cache, appelle [loader] et met en cache
  /// 
  /// Usage:
  /// ```dart
  /// final user = await cache.getOrLoad(
  ///   'user_123',
  ///   () => api.fetchUser('123'),
  /// );
  /// ```
  Future<V> getOrLoad(
    K key,
    Future<V> Function() loader, {
    Duration? ttl,
  }) async {
    // 1. Essayer de récupérer du cache
    final cached = await get(key);
    if (cached != null) {
      return cached;
    }
    
    // 2. Sinon, charger et mettre en cache
    final value = await loader();
    await set(key, value, ttl: ttl);
    return value;
  }

  /// Invalide une entrée spécifique
  Future<void> invalidate(K key) async {
    _cache.remove(key);
  }

  /// Invalide toutes les entrées qui matchent une condition
  /// 
  /// Usage:
  /// ```dart
  /// cache.invalidateWhere((key, value) => key.startsWith('user_'));
  /// ```
  Future<void> invalidateWhere(bool Function(K key, V value) predicate) async {
    final keysToRemove = <K>[];
    
    _cache.forEach((key, entry) {
      if (predicate(key, entry.value)) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Vide complètement le cache
  Future<void> clear() async {
    _cache.clear();
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }

  /// Nettoie les entrées expirées
  /// 
  /// À appeler périodiquement (ex: toutes les heures)
  Future<void> cleanup() async {
    final keysToRemove = <K>[];
    
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _cache.remove(key);
      _evictions++;
    }
  }

  /// Statistiques du cache (pour monitoring)
  CacheStats get stats => CacheStats(
        size: _cache.length,
        maxSize: maxSize,
        hits: _hits,
        misses: _misses,
        evictions: _evictions,
      );

  /// Taux de hit (entre 0.0 et 1.0)
  /// 
  /// > 0.8 = excellent
  /// > 0.5 = bon
  /// < 0.3 = à revoir
  double get hitRate {
    final total = _hits + _misses;
    if (total == 0) return 0.0;
    return _hits / total;
  }

  /// Log les stats (utile pour debugging)
  void logStats() {
    print('📊 Cache Stats:');
    print('  Size: ${_cache.length}/$maxSize');
    print('  Hits: $_hits | Misses: $_misses');
    print('  Hit Rate: ${(hitRate * 100).toStringAsFixed(1)}%');
    print('  Evictions: $_evictions');
  }
}

/// Entrée de cache avec métadonnées
class _CachedEntry<V> {
  final V value;
  final DateTime expiresAt;
  DateTime lastAccessed;

  _CachedEntry({
    required this.value,
    required this.expiresAt,
  }) : lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void updateAccessTime() {
    lastAccessed = DateTime.now();
  }
}

/// Statistiques du cache
class CacheStats {
  final int size;
  final int maxSize;
  final int hits;
  final int misses;
  final int evictions;

  CacheStats({
    required this.size,
    required this.maxSize,
    required this.hits,
    required this.misses,
    required this.evictions,
  });

  double get hitRate {
    final total = hits + misses;
    if (total == 0) return 0.0;
    return hits / total;
  }

  double get fillRate => size / maxSize;

  @override
  String toString() {
    return 'CacheStats(size: $size/$maxSize, hits: $hits, misses: $misses, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Implementation interne d'un LRU Map
/// Utilise un LinkedHashMap qui maintient l'ordre d'insertion
/// et évince l'élément le moins récemment utilisé quand la taille max est atteinte
class _LruMap<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  _LruMap(this._maxSize);

  V? operator [](K key) {
    final value = _map.remove(key);
    if (value != null) {
      // Réinsérer à la fin (le plus récemment utilisé)
      _map[key] = value;
    }
    return value;
  }

  void operator []=(K key, V value) {
    // Si la clé existe déjà, la supprimer d'abord
    _map.remove(key);
    
    // Ajouter à la fin
    _map[key] = value;
    
    // Éviction LRU si nécessaire
    if (_map.length > _maxSize) {
      // Supprimer le premier élément (le plus ancien)
      _map.remove(_map.keys.first);
    }
  }

  V? remove(K key) => _map.remove(key);

  void clear() => _map.clear();

  int get length => _map.length;

  void forEach(void Function(K key, V value) action) {
    _map.forEach(action);
  }

  Iterable<K> get keys => _map.keys;
  
  Iterable<V> get values => _map.values;
}

