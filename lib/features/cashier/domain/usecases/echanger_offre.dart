import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

class EchangerOffreUseCase {
  final CaissierRepository repository;
  final AuthRepository authRepository;
  EchangerOffreUseCase({required this.repository , required this.authRepository});

  Future<void> execute({
    required String clientId,
    required String magasinId,
    required String offreId,
    required double montantSolde,
    required int points,
  }) async {
    try {
      // First, verify client has enough balance
      final clientSolde = await repository.getClientSolde(
        clientId: clientId,
        magasinId: magasinId,
      );

      if (clientSolde < montantSolde) {
        throw Exception('Solde insuffisant pour cette offre');
      }

      // Exchange the offer
      await repository.echangerOffre(
        clientId: clientId,
        magasinId: magasinId,
        offreId: offreId,
        montantSolde: montantSolde,
        points: points,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'échange: ${e.toString()}');
    }
  }
}