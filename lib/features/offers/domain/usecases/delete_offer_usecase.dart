import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';

class DeleteOfferUseCase {
    final OfferRepository repository;
  final AuthRepository authRepository; // Ajoutez cette dépendance
  DeleteOfferUseCase({
    required this.repository,
    required this.authRepository,
  });
  Future<void> execute(String id) async {
    await repository.deleteOffer(id);
  }
}