/// Use case pour ajouter du solde au compte fidélité d'un client.
///
/// Cette use case implémente la logique métier pour l'ajout de solde:
/// - Validation du montant
/// - Calcul des points
/// - Application des offres actives
/// - Mise à jour du solde et points
/// - Historique de transaction
///
/// ### Exemple d'utilisation:
/// ```dart
/// final result = await ajouterSoldeUseCase.execute(
///   clientId: 'client_123',
///   magasinId: 'magasin_456',
///   montant: 100.0,
/// );
/// print('Nouveau solde: ${result.solde}');
/// print('Nouveaux points: ${result.points}');
/// ```
///
/// ### Business Rules:
/// - Montant minimum: 1 MAD
/// - Conversion: 10 MAD = 1 point (configurable)
/// - Les offres actives sont automatiquement appliquées
/// - Points arrondis à l'unité inférieure
///
/// ### Errors:
/// Peut lever une exception si:
/// - Le client n'existe pas
/// - Le magasin n'existe pas
/// - Problème réseau
library;

import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

/// Use case pour ajouter du solde à un client.
///
/// Encapsule la logique d'ajout de solde avec application
/// automatique des offres promotionnelles.
class AjouterSoldeUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [AjouterSoldeUseCase].
  ///
  /// [repository] - Repository injecté via GetIt
  AjouterSoldeUseCase({required this.repository});

  /// Exécute l'ajout de solde.
  ///
  /// [clientId] - ID unique du client
  /// [magasinId] - ID du magasin effectuant l'opération
  /// [montant] - Montant en MAD à ajouter (doit être > 0)
  ///
  /// Returns: [ClientMagasinEntity] avec solde et points mis à jour
  ///
  /// Throws: Exception si client/magasin invalide ou erreur réseau
  Future<ClientMagasinEntity> execute({
    required String clientId,
    required String magasinId,
    required double montant,
  }) async {
    // Validation du montant (business rule)
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à 0');
    }

    // Délégation au repository avec application des offres
    return await repository.ajouterSoldeEtAppliquerOffres(
      clientId: clientId,
      magasinId: magasinId,
      montant: montant,
    );
  }
}
