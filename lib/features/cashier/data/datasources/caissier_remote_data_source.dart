import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';

class CaissierRemoteDataSource {
  final supabase = SupabaseService.client;

  Future<ClientMagasinEntity> ajouterSolde({
    required String clientId,
    required String magasinId,
    required double montant,
  }) async {
    try {
      // First, check if record exists
      final existingRecord = await supabase
          .from('clientmagasin')
          .select('solde')
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId)
          .maybeSingle();

      double newSolde = montant;

      if (existingRecord != null) {
        // Add to existing solde
        final currentSolde = (existingRecord['solde'] as num?)?.toDouble() ?? 0.0;
        newSolde = currentSolde + montant;

        // Update existing record
        final response = await supabase
            .from('clientmagasin')
            .update({'solde': newSolde})
            .eq('client_id', clientId)
            .eq('magasin_id', magasinId)
            .select()
            .single();

        return ClientMagasinEntity.fromJson(response);
      } else {
        // Insert new record
        final response = await supabase
            .from('clientmagasin')
            .insert({
              'client_id': clientId,
              'magasin_id': magasinId,
              'solde': newSolde,
            })
            .select()
            .single();

        return ClientMagasinEntity.fromJson(response);
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du solde: ${e.toString()}');
    }
  }

  Future<List<Offer>> getOffresDisponibles(String magasinId) async {
    try {
      final response = await supabase
          .from('offers')
          .select()
          .eq('magasin_id', magasinId)
          .eq('is_active', true);

      return response.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des offres: ${e.toString()}');
    }
  }

  Future<double> getClientSolde({
    required String clientId,
    required String magasinId,
  }) async {
    try {
      final response = await supabase
          .from('clientmagasin')
          .select('solde')
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId)
          .maybeSingle();

      if (response != null) {
        return (response['solde'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du solde: ${e.toString()}');
    }
  }

  Future<void> echangerOffre({
    required String clientId,
    required String magasinId,
    required String offreId,
    required double montantSolde,
    required int points,
  }) async {
    try {
      // Start a transaction-like operation
      // 1. Get current client balance
      final currentSolde = await getClientSolde(
        clientId: clientId,
        magasinId: magasinId,
      );

      if (currentSolde < montantSolde) {
        throw Exception('Solde insuffisant');
      }

      // 2. Update client balance (subtract solde)
      final newSolde = currentSolde - montantSolde;
      await supabase
          .from('clientmagasin')
          .update({'solde': newSolde})
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId);

      // 3. Add points to client
      await _addPointsToClient(
        clientId: clientId,
        magasinId: magasinId,
        points: points,
      );

      // 4. Record the exchange transaction
      // await supabase.from('echanges').insert({
      //   'client_id': clientId,
      //   'magasin_id': magasinId,
      //   'offre_id': offreId,
      //   'montant_solde': montantSolde,
      //   'points_obtenus': points,
      //   'date_echange': DateTime.now().toIso8601String(),
      // });
    } catch (e) {
      throw Exception('Erreur lors de l\'échange: ${e.toString()}');
    }
  }

  Future<void> _addPointsToClient({
    required String clientId,
    required String magasinId,
    required int points,
  }) async {
    // Check if client points record exists
    final existingPoints = await supabase
        .from('clientmagasin')
        .select('cumulpoint')
        .eq('client_id', clientId)
        .eq('magasin_id', magasinId)
        .maybeSingle();

    if (existingPoints != null) {
      final currentPoints = (existingPoints['cumulpoint'] as int?) ?? 0;
      final newPoints = currentPoints + points;

      await supabase
          .from('clientmagasin')
          .update({'cumulpoint': newPoints})
          .eq('client_id', clientId)
          .eq('magasin_id', magasinId);
    } else {
      // This shouldn't happen if we're exchanging, but handle it
      await supabase
          .from('clientmagasin')
          .insert({
            'client_id': clientId,
            'magasin_id': magasinId,
            'solde': 0.0,
            'cumulpoint': points,
          });
    }
  }
}