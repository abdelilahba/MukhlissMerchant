import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

class  AjouterSoldeClientcode {
  final CaissierRepository repository;

  AjouterSoldeClientcode({required this.repository});

  Future<ClientMagasinEntity> execute({
    required int uniqueCode,
    required String magasinId,
    required double montant,
  }) {
    return repository.ajouterSoldeUniqueColdeAppliquerOffres(
      uniqueCode: uniqueCode,
      magasinId: magasinId,
      montant: montant,
    );
    
  }
}