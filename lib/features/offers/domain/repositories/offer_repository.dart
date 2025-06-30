import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart' show Offer;

abstract class OfferRepository {
  Future<void> addOffer(Offer offer);
  Future<List<Offer>> getOffers();
  Future<void> updateOffer(Offer offer);
Future<void> deleteOffer(String id); 
}
