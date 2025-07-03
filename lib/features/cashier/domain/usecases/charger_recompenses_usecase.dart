import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

class ChargerRecompensesClientResult {
  final List<Reward> rewards;
  final int clientPoints;

  ChargerRecompensesClientResult({
    required this.rewards,
    required this.clientPoints,
  });
}

class ChargerRecompensesClientUseCase {
  final CaissierRepository repository;

  ChargerRecompensesClientUseCase({required this.repository});

  Future<ChargerRecompensesClientResult> execute({
    required String clientId,
    required String magasinId,
  }) async {
    final rewards = await repository.getAvailableRewards(
      clientId: clientId,
      magasinId: magasinId,
    );
    
    final clientPoints = await repository.getClientPoints(
      clientId: clientId,
      magasinId: magasinId,
    );

    return ChargerRecompensesClientResult(
      rewards: rewards,
      clientPoints: clientPoints,
    );
  }
}
