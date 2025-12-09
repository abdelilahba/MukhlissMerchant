import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<MagasinModel?> getCurrentMagasin() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      // Premièrement, trouvez l'ID du magasin associé à cet utilisateur
      final magasinResponse = await _client
          .from('magasins')
          .select('id')
          .eq('id',
              user.id) // Supposant qu'il y a une colonne user_id dans magasins
          .maybeSingle();

      if (magasinResponse == null) {
        return null;
      }

      final magasinId = magasinResponse['id'] as String;

      // Ensuite, récupérez toutes les données du magasin
      final fullMagasinData =
          await _client.from('magasins').select().eq('id', magasinId).single();

      return MagasinModel.fromJson(fullMagasinData);
    } catch (e) {
      return null;
    }
  }

  // update current user

  Future<bool> updateCurrentMagasin(MagasinModel magasindata) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }
      // Convertir le MagasinModel en Map<String, dynamic>
      final Map<String, dynamic> updateData = magasindata.toJson();
      // Supprimer les champs qui ne doivent pas être mis à jour
      updateData.remove('id'); // L'ID ne doit pas être modifié
      updateData.remove(
          'created_at'); // La date de création ne doit pas être modifiée
      final response = await _client
          .from('magasins')
          .update(updateData)
          .eq('id', user.id)
          .select();

      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
