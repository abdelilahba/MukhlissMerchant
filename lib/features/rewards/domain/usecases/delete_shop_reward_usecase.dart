import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';

class DeleteRewardUseCase {
  final RewardRepository repository;
  final AuthRepository authRepository;
  DeleteRewardUseCase({required this.repository , required this.authRepository});

  Future<void> execute(String id) async {
    await repository.deleteReward(id);
  }
}