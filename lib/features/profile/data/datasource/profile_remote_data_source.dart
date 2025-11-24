import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<MagasinModel?> getCurrentMagasin() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('Aucun utilisateur connecté');
      return null;
    }

    print('Recherche du magasin pour l\'utilisateur: ${user.id}');

    try {
      // Premièrement, trouvez l'ID du magasin associé à cet utilisateur
      final magasinResponse = await _client
          .from('magasins')
          .select('id')
          .eq('id', user.id)  // Supposant qu'il y a une colonne user_id dans magasins
          .maybeSingle();

      if (magasinResponse == null) {
        print('Aucun magasin trouvé pour cet utilisateur');
        return null;
      }

      final magasinId = magasinResponse['id'] as String;
      print('ID du magasin trouvé: $magasinId');

      // Ensuite, récupérez toutes les données du magasin
      final fullMagasinData = await _client
          .from('magasins')
          .select()
          .eq('id', magasinId)
          .single();

      print('Données complètes du magasin: $fullMagasinData');
      return MagasinModel.fromJson(fullMagasinData);
    } catch (e) {
      print('Erreur lors de la récupération du magasin: $e');
      return null;
    }
  }

  // update current user 
 
Future<bool> UpdatecurrentMagasin(MagasinModel magasindata) async {
  try {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('Aucun utilisateur connecté');
      return false;
    }
    // Convertir le MagasinModel en Map<String, dynamic>
    final Map<String, dynamic> updateData = magasindata.toJson();  
    // Supprimer les champs qui ne doivent pas être mis à jour
    updateData.remove('id'); // L'ID ne doit pas être modifié
    updateData.remove('created_at'); // La date de création ne doit pas être modifiée
    print('Données à mettre à jour: $updateData');
    final response = await _client
        .from('magasins')
        .update(updateData)
        .eq('id', user.id)
        .select();

    if (response.isNotEmpty) {
      print('Magasin mis à jour avec succès: $response');
      return true;
    } else {
      print('Aucune ligne mise à jour');
      return false;
    }
  } catch (e) {
    print('Erreur lors de la mise à jour du magasin: $e');
    return false;
  }
}

}