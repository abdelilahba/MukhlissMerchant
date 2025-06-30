import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart' show AuthRepository;
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';

class OffresClientResult {
  final List<Offer> offers;
  final double clientSolde;

  OffresClientResult({
    required this.offers,
    required this.clientSolde,
  });
}

class ChargerOffresClientUseCase {
  final CaissierRepository repository;
  final AuthRepository authRepository; 
  ChargerOffresClientUseCase({required this.repository , required this.authRepository});

  Future<OffresClientResult> execute({
    required String clientId,
    required String magasinId,
  }) async {
    try {
      // Get client's current balance
      final clientSolde = await repository.getClientSolde(
        clientId: clientId,
        magasinId: magasinId,
      );

      // Get all available offers for this magasin
      final allOffers = await repository.getOffresDisponibles(magasinId);

      return OffresClientResult(
        offers: allOffers,
        clientSolde: clientSolde,
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement des offres: ${e.toString()}');
    }
  }
}