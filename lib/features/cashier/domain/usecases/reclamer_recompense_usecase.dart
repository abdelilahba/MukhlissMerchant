import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

class ReclamerRecompenseUseCase {
  final CaissierRepository repository;

  ReclamerRecompenseUseCase({required this.repository});

  Future<void> execute({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    return await repository.claimReward(
      clientId: clientId,
      magasinId: magasinId,
      rewardId: rewardId,
      pointsRequired: pointsRequired,
    );
  }
}