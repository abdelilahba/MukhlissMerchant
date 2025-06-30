// features/offers/data/datasources/offer_remote_data_source.dart
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';

class OfferRemoteDataSource {
  final supabase = SupabaseService.client;

  Future<List<Offer>> getOffersByStore(String storeId) async {
    final response = await supabase
        .from('offers')
        .select('*')
        .eq('magasin_id', storeId) // Filtre par ID du magasin
        .order('created_at', ascending: false);
    return response.map((json) => Offer.fromJson(json)).toList();
  }
 
  Future<void> addOffer(Offer offer) async {
    await supabase.from('offers').insert(offer.toJson());
  }

  Future<void> updateOffer(Offer offer) async {
    await supabase.from('offers').update(offer.toJson()).eq('id', offer.id);
  }

  Future<void> deleteOffer(String id) async {
    await supabase.from('offers').delete().eq('id', id);
  }
}
