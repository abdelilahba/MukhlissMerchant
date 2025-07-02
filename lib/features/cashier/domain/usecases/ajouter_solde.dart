import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

class AjouterSoldeUseCase {
  final CaissierRepository repository;

  AjouterSoldeUseCase({required this.repository} );

Future<ClientMagasinEntity> execute({
  required String clientId,
  required String magasinId,
  required double montant,
}) async {
  return await repository.ajouterSoldeEtAppliquerOffres(
    clientId: clientId,
    magasinId: magasinId,
    montant: montant,
  );
}
}