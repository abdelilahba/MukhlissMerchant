import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';
import 'package:uuid/uuid.dart';

class AddOfferUseCase {
  final OfferRepository repository;
  final AuthRepository authRepository; // Ajoutez cette dépendance

  AddOfferUseCase({
    required this.repository,
    required this.authRepository,
  });

  Future<void> execute({
    required double minAmount,
    required int pointsGiven,
  }) async {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('User not authenticated');
    if (pointsGiven <= 0) throw ArgumentError('Points must be > 0');

    await repository.addOffer(
      Offer(
        id: const Uuid().v4(),
        minAmount: minAmount,
        pointsGiven: pointsGiven,
        magasinId: currentUser.id, // Associe au magasin connecté
      ),
    );
  }
}