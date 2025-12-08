/// Use case pour réclamer une récompense.
///
/// Permet à un client de convertir ses points en récompense.
/// Met à jour les points du client et crée un historique.
///
/// ### Exemple d'utilisation:
/// ```dart
/// await reclamerRecompense.execute(
///   clientId: 'client_123',
///   magasinId: 'magasin_456',
///   rewardId: 'reward_789',
///   pointsRequired: 100,
/// );
/// ```
///
/// ### Business Rules:
/// - Le client doit avoir assez de points
/// - La récompense doit être active
/// - Points déduits immédiatement
/// - Transaction enregistrée
///
/// ### Errors:
/// Peut lever une exception si:
/// - Points insuffisants
/// - Récompense inactive
/// - Récompense déjà réclamée
library;

import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

/// Use case pour réclamer une récompense.
///
/// Déduit les points du client et enregistre
/// la réclamation de la récompense.
class ReclamerRecompenseUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [ReclamerRecompenseUseCase].
  ReclamerRecompenseUseCase({required this.repository});

  /// Exécute la réclamation de récompense.
  ///
  /// [clientId] - ID du client
  /// [magasinId] - ID du magasin
  /// [rewardId] - ID de la récompense
  /// [pointsRequired] - Points à déduire
  ///
  /// Throws: Exception si points insuffisants ou récompense invalide
  Future<void> execute({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    // Validation
    if (pointsRequired <= 0) {
      throw ArgumentError('Les points requis doivent être positifs');
    }

    return await repository.claimReward(
      clientId: clientId,
      magasinId: magasinId,
      rewardId: rewardId,
      pointsRequired: pointsRequired,
    );
  }
}
