import 'package:mukhlissmagasin/core/services/cache_entry.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  // ✅ Cache en mémoire avec TTL
  CacheEntry<MagasinModel?>? _magasinCache;

  // Configuration du cache
  static const Duration _magasinCacheTTL = Duration(minutes: 15);

  Future<MagasinModel?> getCurrentMagasin({bool forceRefresh = false}) async {
    // Vérifier le cache si pas de forceRefresh
    if (!forceRefresh) {
      final cached = _magasinCache;
      if (cached != null && !cached.isExpired) {
        return cached.data;
      }
    }

    await SupabaseService.ensureValidSession();
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      // ✅ Simplifié: une seule requête au lieu de deux
      final fullMagasinData = await _client
          .from('magasins')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (fullMagasinData == null) {
        return null;
      }

      final magasin = MagasinModel.fromJson(fullMagasinData);

      // Mettre en cache
      _magasinCache = CacheEntry(
        data: magasin,
        timestamp: DateTime.now(),
        ttl: _magasinCacheTTL,
      );

      return magasin;
    } catch (e) {
      return null;
    }
  }

  /// Met à jour le magasin et invalide le cache
  Future<bool> updateCurrentMagasin(MagasinModel magasindata) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }
      // Convertir le MagasinModel en Map<String, dynamic>
      final Map<String, dynamic> updateData = magasindata.toJson();
      // Supprimer les champs qui ne doivent pas être mis à jour
      updateData.remove('id');
      updateData.remove('created_at');
      final response = await _client
          .from('magasins')
          .update(updateData)
          .eq('id', user.id)
          .select();

      if (response.isNotEmpty) {
        // ✅ Write-through: mettre à jour le cache avec les nouvelles données
        _magasinCache = CacheEntry(
          data: MagasinModel.fromJson(response.first),
          timestamp: DateTime.now(),
          ttl: _magasinCacheTTL,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Vide le cache (utile pour logout)
  void clearCache() {
    _magasinCache = null;
  }
}
