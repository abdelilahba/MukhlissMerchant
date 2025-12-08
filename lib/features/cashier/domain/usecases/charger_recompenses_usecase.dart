/// Use case pour charger les récompenses disponibles d'un client.
///
/// Récupère la liste des récompenses que le client peut réclamer
/// en fonction de ses points accumulés.
///
/// ### Exemple d'utilisation:
/// ```dart
/// final result = await chargerRecompensesClient.execute(
///   clientId: 'client_123',
///   magasinId: 'magasin_456',
/// );
/// print('Points: ${result.clientPoints}');
/// print('Récompenses disponibles: ${result.rewards.length}');
/// ```
///
/// ### Business Rules:
/// - Seules les récompenses actives sont retournées
/// - Filtrées par points suffisants
/// - Triées par popularité/coût
library;

import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

/// Résultat du chargement des récompenses client.
///
/// Contient:
/// - Liste des récompenses disponibles
/// - Points actuels du client
class ChargerRecompensesClientResult {
  /// Liste des récompenses disponibles
  final List<Reward> rewards;

  /// Points actuels du client
  final int clientPoints;

  /// Crée un résultat de chargement.
  ChargerRecompensesClientResult({
    required this.rewards,
    required this.clientPoints,
  });

  /// Récompenses que le client peut réclamer (points suffisants)
  List<Reward> get claimableRewards =>
      rewards.where((r) => r.requiredPoints <= clientPoints).toList();

  /// Le client a-t-il au moins une récompense disponible?
  bool get hasClaimableRewards => claimableRewards.isNotEmpty;
}

/// Use case pour charger les récompenses disponibles.
///
/// Récupère en parallèle:
/// - Les récompenses du magasin
/// - Les points actuels du client
class ChargerRecompensesClientUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [ChargerRecompensesClientUseCase].
  ChargerRecompensesClientUseCase({required this.repository});

  /// Exécute le chargement des récompenses.
  ///
  /// [clientId] - ID du client
  /// [magasinId] - ID du magasin
  ///
  /// Returns: [ChargerRecompensesClientResult] avec récompenses et points
  Future<ChargerRecompensesClientResult> execute({
    required String clientId,
    required String magasinId,
  }) async {
    // Exécution parallèle pour performance
    final results = await Future.wait([
      repository.getAvailableRewards(
        clientId: clientId,
        magasinId: magasinId,
      ),
      repository.getClientPoints(
        clientId: clientId,
        magasinId: magasinId,
      ),
    ]);

    final rewards = results[0] as List<Reward>;
    final clientPoints = results[1] as int;

    return ChargerRecompensesClientResult(
      rewards: rewards,
      clientPoints: clientPoints,
    );
  }
}
