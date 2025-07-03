import 'package:bloc/bloc.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/add_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/delete_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/get_shop_rewards_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/update_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  final GetShopRewardsUseCase getShopRewardsUseCase;
  final AddRewardUseCase addRewardUseCase;
  final UpdateShopRewardUsecase updateRewardUseCase;
  final DeleteRewardUseCase deleteRewardUseCase;
  RewardCubit({
    required this.getShopRewardsUseCase,
    required this.addRewardUseCase,
    required this.updateRewardUseCase,
    required this.deleteRewardUseCase,
  }) : super(RewardInitial());

  Future<void> loadShopRewards() async {
    emit(RewardLoading());
    try {
      final rewards = await getShopRewardsUseCase.execute();
      emit(RewardsLoaded(rewards));
    } catch (e) {
      emit(RewardError('Erreur de chargement: ${e.toString()}'));
    }
  }

  Future<void> addReward({
    required String title,
    required String description,
    required int requiredPoints,
    String? imagePath, // Changé de imageUrl à imagePath
  }) async {
    emit(RewardLoading());
    try {
      await addRewardUseCase.execute(
        title: title,
        description: description,
        requiredPoints: requiredPoints,
      );
      await loadShopRewards(); // Recharge la liste mise à jour
    } catch (e) {
      emit(RewardError('Erreur d\'ajout: ${e.toString()}'));
    }
  }
Future<void> updateReward({
    required String id,
    required String title,
    required String description,
    required int requiredPoints,
    String? imagePath,
  }) async {
    try {
      emit(RewardLoading());
      // Call your repository to update the reward
      await updateRewardUseCase.execute(
        id: id,
        title: title,
        description: description,
        requiredPoints: requiredPoints,
        imagePath: imagePath,
      );
      await loadShopRewards();
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }
  void showRewardDetail(Reward reward) {
    emit(RewardDetailLoaded(reward));
  }

  void returnToList() {
    if (state is RewardsLoaded) {
      emit(state as RewardsLoaded);
    }
  }

  Future<void> deleteReward(String id) async {
    emit(RewardLoading());
    try {
      await deleteRewardUseCase.execute(id);
      await loadShopRewards();
    } catch (e) {
      emit(RewardError('Delete error: ${e.toString()}'));
    }
  }
}
