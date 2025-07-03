// features/rewards/domain/repositories/reward_repository.dart
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

abstract class RewardRepository {
  Future<List<Reward>> getShopRewards();
  Future<void> addReward(Reward reward); // Ajout du paramètre imagePath
  Future<void> updateReward(Reward reward); // 
    Future<void> deleteReward(String id);

}