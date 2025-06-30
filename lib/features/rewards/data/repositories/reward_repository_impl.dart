// features/rewards/data/repositories/reward_repository_impl.dart
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';
import 'package:mukhlissmagasin/features/rewards/data/datasources/reward_remote_data_source.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  RewardRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<List<Reward>> getShopRewards() async {
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    return await remoteDataSource.getRewardsByStore(currentUser.id);
  }

  @override
  Future<void> addReward(Reward reward, {String? imagePath}) async {
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    
    final rewardWithShopId = reward.copyWith(shopId: currentUser.id);
    await remoteDataSource.addReward(rewardWithShopId, imagePath: imagePath);
  }

  @override
  Future<void> updateReward(Reward reward) async {
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    
    final rewardWithShopId = reward.copyWith(shopId: currentUser.id);
    await remoteDataSource.updateReward(rewardWithShopId);
  }

    @override
  Future<void> deleteReward(String id) async {
    await remoteDataSource.deleteReward(id);
  }
}