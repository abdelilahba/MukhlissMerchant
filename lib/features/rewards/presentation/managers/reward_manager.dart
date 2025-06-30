import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/add_reward_screen.dart';

class RewardManager {
  final RewardCubit _cubit;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  String? imagePath; // Changé de imageUrl à imagePath pour plus de clarté

  RewardManager(this._cubit);

  Future<void> loadRewards() async => await _cubit.loadShopRewards();

  Future<void> addReward() async {
    await _cubit.addReward(
      title: titleController.text,
      description: descriptionController.text,
      requiredPoints: int.parse(pointsController.text),
      imagePath: imagePath, 
    );
  }
 Future<void> updateReward(String rewardId) async {
    await _cubit.updateReward(
      id: rewardId,
      title: titleController.text,
      description: descriptionController.text,
      requiredPoints: int.parse(pointsController.text),
      imagePath: imagePath,
    );
  }
  void showRewardDetail(Reward reward) => _cubit.showRewardDetail(reward);
void navigateToEditReward(BuildContext context, Reward reward) {
    // Populate the form fields with existing reward data
    titleController.text = reward.name;
    pointsController.text = reward.requiredPoints.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRewardScreen(reward: reward),
      ),
    );
  }
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    pointsController.clear();
    imagePath = null;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    pointsController.dispose();
  }

  void setImagePath(String? path) {
    // Nouvelle méthode
    imagePath = path;
  }

  void navigateToAddReward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRewardScreen()),
    );
  }
    Future<void> deleteReward(String id) async {
    await _cubit.deleteReward(id);
  }
}
