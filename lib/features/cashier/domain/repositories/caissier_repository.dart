import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

abstract class CaissierRepository {



  Future<double> getClientSolde({
    required String clientId,
    required String magasinId,
  });

  Future<int> getClientPoints({
    required String clientId,
    required String magasinId,
  });

  Future<List<Reward>> getAvailableRewards({
    required String clientId,
    required String magasinId,
  });



  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  });

  Future<ClientMagasinEntity> ajouterSoldeEtAppliquerOffres({
    required String clientId,
    required String magasinId,
    required double montant,
  });
}