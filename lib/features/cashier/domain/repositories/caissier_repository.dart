import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

abstract class CaissierRepository {
  Future<ClientMagasinEntity> ajouterSolde({
    required String clientId,
    required String magasinId,
    required double montant,
  });

  Future<List<Offer>> getOffresDisponibles(String magasinId);

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

  Future<void> echangerOffre({
    required String clientId,
    required String magasinId,
    required String offreId,
    required double montantSolde,
    required int points,
  });

  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  });
}