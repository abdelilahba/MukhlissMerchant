// features/rewards/domain/repositories/reward_repository.dart
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/data/datasources/reward_remote_data_source.dart';

abstract class RewardRepository {
  Future<List<Reward>> getShopRewards();
  Future<void> addReward(Reward reward);
  Future<void> updateReward(Reward reward);
  Future<void> deleteReward(String id);
  Future<List<PresetImage>> getPresetImages(); // NEW
}