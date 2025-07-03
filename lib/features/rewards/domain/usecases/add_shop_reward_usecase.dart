import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';
import 'package:uuid/uuid.dart';

class AddRewardUseCase {
  final RewardRepository repository;
  final AuthRepository authRepository;

  AddRewardUseCase({
    required this.repository,
    required this.authRepository,
  });

Future<void> execute({
    required String title,
    required String description,
    required int requiredPoints,
  }) async {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');
    if (requiredPoints <= 0) throw ArgumentError('Les points doivent être > 0');

    final reward = Reward(
     id: const Uuid().v4(),
      name: title,
      requiredPoints: requiredPoints,
      shopId: currentUser.id,
      // imageUrl sera défini par le repository après l'upload
    );

    await repository.addReward(reward);
  }
}