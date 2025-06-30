// features/rewards/data/datasources/reward_remote_data_source.dart
import 'dart:io';

import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardRemoteDataSource {
  final supabase = SupabaseService.client;
  static const String rewardsBucket = 'rewards';

Future<String> _uploadImage(String filePath) async {
  try {
    final file = File(filePath);
    final fileExtension = filePath.split('.').last;
    final fileName = 'reward_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    
    // Nouvelle méthode pour upload qui gère les erreurs différemment
    await supabase.storage
      .from(rewardsBucket)
      .upload(fileName, file, fileOptions: FileOptions(
        contentType: 'image/$fileExtension',
      ));

    return _getPublicUrl(fileName);
  } on StorageException catch (e) {
    throw Exception('Erreur d\'upload: ${e.message}');
  } catch (e) {
    throw Exception('Erreur inattendue: $e');
  }
}
  String _getPublicUrl(String fileName) {
    return SupabaseService.client.storage
        .from(rewardsBucket)
        .getPublicUrl(fileName);
  }

  // Récupère toutes les récompenses d'un magasin
  Future<List<Reward>> getRewardsByStore(String storeId) async {
    final response = await supabase
        .from('rewards')
        .select('*') // Jointure avec la table shops
        .eq('magasin_id', storeId); // Filtre par ID du magasin

    return response.map((json) => Reward.fromJson(json)).toList();
  }

  // Ajoute une nouvelle récompense
Future<void> addReward(Reward reward, {String? imagePath}) async {
  try {
    String? imageUrl;
    
    if (imagePath != null) {
      imageUrl = await _uploadImage(imagePath);
    }

    await supabase.from('rewards').insert({
      ...reward.toJson(),
      'image_url': imageUrl,
    });
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
}
