import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/data/datasources/caissier_remote_data_source.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaissierRepositoryImpl implements CaissierRepository {
  final CaissierRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  CaissierRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

 


  @override
  Future<double> getClientSolde({
    required String clientId,
    required String magasinId,
  }) async {
    return await remoteDataSource.getClientSolde(
      clientId: clientId,
      magasinId: magasinId,
    );
  }

  @override
  Future<int> getClientPoints({
    required String clientId,
    required String magasinId,
  }) async {
    return await remoteDataSource.getClientPoints(
      clientId: clientId,
      magasinId: magasinId,
    );
  }

  @override
  Future<List<Reward>> getAvailableRewards({
    required String clientId,
    required String magasinId,
  }) async {
    return await remoteDataSource.getAvailableRewards(
      clientId: clientId,
      magasinId: magasinId,
    );
  }



  @override
  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    // 1. Réclamer la récompense
    await remoteDataSource.claimReward(
      clientId: clientId,
      magasinId: magasinId,
      rewardId: rewardId,
      pointsRequired: pointsRequired,
    );
    
    // 2. ✅ Invalider le cache pour garantir des données à jour
    remoteDataSource.invalidateCache(
      clientId: clientId,
      magasinId: magasinId,
    );
  }
   @override
  Future<ClientMagasinEntity> ajouterSoldeEtAppliquerOffres({
    required String clientId,
    required String magasinId,
    required double montant,
  }) async {
    // 1. Ajouter le solde et appliquer les offres
    final result = await remoteDataSource.ajouterSoldeEtAppliquerOffres(
      clientId: clientId,
      magasinId: magasinId,
      montant: montant,
    );
    
    // 2. ✅ Invalider le cache pour garantir des données à jour
    remoteDataSource.invalidateCache(
      clientId: clientId,
      magasinId: magasinId,
    );
    
    return result;
  }

@override
  User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }
 
 @override
  Future<MagasinModel> currentMagazin() async {
    return await remoteDataSource.currentMagazin();
  }

  @override
  Future<ClientMagasinEntity> ajouterSoldeUniqueColdeAppliquerOffres({
    required int uniqueCode,
    required String magasinId,
    required double montant,
  }) {
     return remoteDataSource.ajouterSoldeUniqueColdeAppliquerOffres(uniqueCode: uniqueCode, magasinId: magasinId, montant: montant);
  }


  @override
  Future<Client> getClientByCodeUnique({
    required int uniqueCode,
  }) {
    return remoteDataSource.getClientByCodeUnique(
      uniqueCode: uniqueCode,
    );
  }
}
