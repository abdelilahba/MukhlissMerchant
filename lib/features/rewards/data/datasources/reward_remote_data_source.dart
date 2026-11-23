// features/rewards/data/datasources/reward_remote_data_source.dart
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardRemoteDataSource {
  final supabase = SupabaseService.client;
  static const String rewardsBucket = 'rewards';

  // Récupère toutes les récompenses d'un magasin
  Future<List<Reward>> getRewardsByStore(String storeId) async {
    final response = await supabase
        .from('rewards')
        .select('*')
        .eq('magasin_id', storeId);

    return response.map((json) => Reward.fromJson(json)).toList();
  }

  // Ajoute une nouvelle récompense
  Future<void> addReward(Reward reward) async {
    try {
      await supabase.from('rewards').insert(reward.toJson());
    } on PostgrestException catch (e) {
      throw Exception('Erreur de base de données: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Met à jour une récompense existante
  Future<void> updateReward(Reward reward) async {
    await supabase.from('rewards').update(reward.toJson()).eq('id', reward.id);
  }

  // Supprime une récompense
  Future<void> deleteReward(String id) async {
    try {
      await supabase.from('rewards').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Enregistre une réclamation de récompense
  Future<void> claimReward(String userId, String rewardId) async {
    await supabase.from('reward_claims').insert({
      'user_id': userId,
      'reward_id': rewardId,
      'claimed_at': DateTime.now().toIso8601String(),
    });
  }

  /// NEW: Récupère les images prédéfinies pour une catégorie donnée
  /// Retourne les images de la catégorie + les images par défaut (category_id NULL)
  Future<List<PresetImage>> getPresetImages(int categoryId) async {
    final response = await supabase
        .from('reward_preset_images')
        .select('*')
        .or('category_id.eq.$categoryId,category_id.is.null')
        .order('sort_order', ascending: true);

    return response.map((json) => PresetImage.fromJson(json)).toList();
  }

  /// NEW: Récupère le category_id du magasin connecté
  Future<int?> getMagasinCategoryId(String magasinId) async {
    final response = await supabase
        .from('magasins')
        .select('Categorieid')
        .eq('id', magasinId)
        .maybeSingle();

    if (response == null) return null;
    return response['Categorieid'] as int?;
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
