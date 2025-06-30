import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';

class GetShopRewardsUseCase {
  final RewardRepository repository;

  GetShopRewardsUseCase({required this.repository});

  Future<List<Reward>> execute() async { // Plus besoin de paramètre
    return await repository.getShopRewards();
  }
}
