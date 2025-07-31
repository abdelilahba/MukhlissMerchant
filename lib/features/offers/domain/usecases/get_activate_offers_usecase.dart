


import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';

class GetActivateOffersUsecase {
   late final OfferRepository repository;
  GetActivateOffersUsecase({required this.repository});
  Future<List<Offer>> execute() async {
    return await repository.getOffers();
  }
}