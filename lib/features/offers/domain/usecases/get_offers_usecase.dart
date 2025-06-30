import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart' show OfferRepository;

class GetOffersUseCase {
  late final OfferRepository repository;
  GetOffersUseCase({required this.repository});
  Future<List<Offer>> execute() async {
    return await repository.getOffers();
  }
}
