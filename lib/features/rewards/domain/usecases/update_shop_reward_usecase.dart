import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';

class UpdateShopRewardUsecase {
  final RewardRepository repository;
  final AuthRepository authRepository;

  UpdateShopRewardUsecase({
    required this.repository,
    required this.authRepository,
  });

  Future<void> execute({
    required String id, // Add required id parameter
    required String title,
    required String description,
    required int requiredPoints,
    String? imagePath,
  }) async {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');
    if (requiredPoints <= 0) throw ArgumentError('Les points doivent être > 0');

    final reward = Reward(
      id: id, // Use the existing reward ID
      name: title,
      requiredPoints: requiredPoints,
      shopId: currentUser.id,
    );

    await repository.updateReward(reward);
  }
}