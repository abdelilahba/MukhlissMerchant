import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/data/datasources/caissier_remote_data_source.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

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
    return await remoteDataSource.claimReward(
      clientId: clientId,
      magasinId: magasinId,
      rewardId: rewardId,
      pointsRequired: pointsRequired,
    );
  }
   @override
  Future<ClientMagasinEntity> ajouterSoldeEtAppliquerOffres({
    required String clientId,
    required String magasinId,
    required double montant,
  }) {
    return remoteDataSource.ajouterSoldeEtAppliquerOffres(
      clientId: clientId,
      magasinId: magasinId,
      montant: montant,
    );
  }
}
