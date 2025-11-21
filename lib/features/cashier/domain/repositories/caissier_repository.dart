import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart' show MagasinModel;

import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

   User? getCurrentUser();

  Future<MagasinModel> currentMagazin();

  Future<ClientMagasinEntity> ajouterSoldeUniqueColdeAppliquerOffres({
  required int uniqueCode,
  required String magasinId,
  required double montant,
}) ;

  Future<Client> getClientByCodeUnique({
    required int uniqueCode,
  });

}


   
