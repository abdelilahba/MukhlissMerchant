import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';

class UpdateOfferUseCase {
  final OfferRepository repository;
  final AuthRepository authRepository; // Ajoutez cette dépendance
  UpdateOfferUseCase({required this.repository , required this.authRepository});

  Future<void> execute({
    required String id,
    required double minAmount,
    required int pointsGiven,
  }) async {
        final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('User not authenticated');
    if (pointsGiven <= 0) throw ArgumentError('Points must be > 0');
    if (pointsGiven <= 0) throw ArgumentError('Points must be > 0');
    
    await repository.updateOffer(
      Offer(
        id: id,
        minAmount: minAmount,
        pointsGiven: pointsGiven,
        // Make sure to preserve the magasinId from the existing offer
        magasinId: currentUser.id, // You'll need to get this from the existing offer
      ),
    );
  }
}