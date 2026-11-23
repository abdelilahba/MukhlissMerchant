import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/add_reward_screen.dart';
import 'package:mukhlissmagasin/features/rewards/data/datasources/reward_remote_data_source.dart';

class RewardManager {
  final RewardCubit _cubit;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  String? selectedImageUrl; // NEW: URL de l'image sélectionnée
  bool isActive = true;

  RewardManager(this._cubit);

  Future<void> loadRewards() async => await _cubit.loadShopRewards();

  /// NEW: Charge les images prédéfinies pour la catégorie du magasin
  Future<List<PresetImage>> loadPresetImages() async {
    return await _cubit.loadPresetImages();
  }

  Future<void> addReward() async {
    await _cubit.addReward(
      title: titleController.text,
      description: descriptionController.text,
      requiredPoints: int.parse(pointsController.text),
      isactive: isActive,
      imageUrl: selectedImageUrl, // NEW
    );
  }

  Future<void> updateReward(String rewardId) async {
    await _cubit.updateReward(
      id: rewardId,
      title: titleController.text,
      description: descriptionController.text,
      requiredPoints: int.parse(pointsController.text),
      isActive: isActive,
      imageUrl: selectedImageUrl, // NEW
    );
  }

  void showRewardDetail(Reward reward) => _cubit.showRewardDetail(reward);

  void navigateToEditReward(BuildContext context, Reward reward) {
    titleController.text = reward.name;
    pointsController.text = reward.requiredPoints.toString();
    isActive = reward.isActive;
    selectedImageUrl = reward.imageUrl; // NEW: pré-remplir l'image
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
    selectedImageUrl = null; // NEW
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    pointsController.dispose();
  }

  void setSelectedImageUrl(String? url) {
    selectedImageUrl = url;
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