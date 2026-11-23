import 'package:bloc/bloc.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/add_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/delete_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/get_shop_rewards_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/update_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_state.dart';
import 'package:mukhlissmagasin/features/rewards/data/datasources/reward_remote_data_source.dart';

class RewardCubit extends Cubit<RewardState> {
  final GetShopRewardsUseCase getShopRewardsUseCase;
  final AddRewardUseCase addRewardUseCase;
  final UpdateShopRewardUsecase updateRewardUseCase;
  final DeleteRewardUseCase deleteRewardUseCase;
  final RewardRepository repository; // NEW: pour accéder aux preset images

  RewardCubit({
    required this.getShopRewardsUseCase,
    required this.addRewardUseCase,
    required this.updateRewardUseCase,
    required this.deleteRewardUseCase,
    required this.repository, // NEW
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
    required bool isactive,
    String? imageUrl, // NEW
  }) async {
    emit(RewardLoading());
    try {
      await addRewardUseCase.execute(
        title: title,
        description: description,
        requiredPoints: requiredPoints,
        isactive: isactive,
        imageUrl: imageUrl, // NEW
      );
      await loadShopRewards();
    } catch (e) {
      emit(RewardError('Erreur d\'ajout: ${e.toString()}'));
    }
  }

  Future<void> updateReward({
    required String id,
    required String title,
    required String description,
    required int requiredPoints,
    required bool isActive,
    String? imageUrl, // NEW
  }) async {
    try {
      emit(RewardLoading());
      await updateRewardUseCase.execute(
        id: id,
        title: title,
        description: description,
        requiredPoints: requiredPoints,
        isActive: isActive,
        imageUrl: imageUrl, // NEW
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

  /// NEW: Charge les images prédéfinies pour la catégorie du magasin
  Future<List<PresetImage>> loadPresetImages() async {
    try {
      return await repository.getPresetImages();
    } catch (e) {
      return [];
    }
  }
}
