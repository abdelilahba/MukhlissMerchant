import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/offers/data/datasources/offer_remote_data_source.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  final OfferRemoteDataSource remoteDataSource;
  final AuthRepository authRepository; // Ajoutez cette dépendance

  OfferRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<void> addOffer(Offer offer) => remoteDataSource.addOffer(offer);

  @override
  Future<List<Offer>> getOffers() async {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    return remoteDataSource.getOffersByStore(
      currentUser.id,
    ); 
  }

  @override
  Future<void> updateOffer(Offer offer) async {
    if (offer.pointsGiven <= 0) throw ArgumentError('Points must be positive');
    await remoteDataSource.updateOffer(offer);
  }

  @override
  Future<void> deleteOffer(String id) async {
    await remoteDataSource.deleteOffer(id);
  }
}
