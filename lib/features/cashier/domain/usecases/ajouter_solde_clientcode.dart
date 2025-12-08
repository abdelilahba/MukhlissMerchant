/// Use case pour ajouter du solde via code unique client.
///
/// Variante de AjouterSoldeUseCase qui utilise le code unique
/// au lieu de l'ID client (plus pratique pour scan/saisie).
///
/// ### Exemple d'utilisation:
/// ```dart
/// final result = await ajouterSoldeClientCode.execute(
///   uniqueCode: 12345678,
///   magasinId: 'magasin_456',
///   montant: 100.0,
/// );
/// print('Nouveau solde: ${result.solde}');
/// ```
///
/// ### Business Rules:
/// - Code unique: 8 chiffres
/// - Montant minimum: 1 MAD
/// - Offres automatiquement appliquées
/// - Points calculés sur le montant
///
/// ### Flow:
/// 1. Recherche client par code unique
/// 2. Ajout du solde
/// 3. Calcul des points
/// 4. Application des offres
/// 5. Retour du résultat
library;

import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

/// Use case pour ajouter du solde via code unique.
///
/// Simplifie le processus en utilisant le code court
/// au lieu de l'ID complet du client.
class AjouterSoldeParCodeUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [AjouterSoldeParCodeUseCase].
  AjouterSoldeParCodeUseCase({required this.repository});

  /// Exécute l'ajout de solde via code unique.
  ///
  /// [uniqueCode] - Code unique du client (8 chiffres)
  /// [magasinId] - ID du magasin effectuant l'opération
  /// [montant] - Montant en MAD à ajouter
  ///
  /// Returns: [ClientMagasinEntity] avec solde et points mis à jour
  ///
  /// Throws: Exception si code invalide ou client non trouvé
  Future<ClientMagasinEntity> execute({
    required int uniqueCode,
    required String magasinId,
    required double montant,
  }) {
    // Validation
    if (uniqueCode <= 0) {
      throw ArgumentError('Le code unique doit être positif');
    }
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à 0');
    }

    return repository.ajouterSoldeUniqueColdeAppliquerOffres(
      uniqueCode: uniqueCode,
      magasinId: magasinId,
      montant: montant,
    );
  }
}

/// Alias pour compatibilité avec l'ancien nom
@Deprecated('Utilisez AjouterSoldeParCodeUseCase à la place')
typedef AjouterSoldeClientcode = AjouterSoldeParCodeUseCase;
