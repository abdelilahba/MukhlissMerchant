/// Classe générique pour gérer le cache en mémoire avec TTL.
/// Utilisée par tous les DataSources pour un cache cohérent.
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
