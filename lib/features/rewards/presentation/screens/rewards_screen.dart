import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/core/widgets/reward_card.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_state.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/managers/reward_manager.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = RewardManager(context.read<RewardCubit>());
    manager.loadRewards();

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: _buildBody(context, manager),
      floatingActionButton: _buildAddRewardButton(context, manager), // Add FAB
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Récompenses'),
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RewardManager manager) {
    return BlocBuilder<RewardCubit, RewardState>(
      builder: (context, state) {
        if (state is RewardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RewardError) {
          return Center(child: Text(state.message));
        }

        if (state is RewardsLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.rewards.length,
            itemBuilder: (context, index) {
              final reward = state.rewards[index];
              return RewardCard(
                reward: reward,
                onTap: () => manager.showRewardDetail(reward),
                onDelete: () => _showDeleteDialog(context, manager, reward.id),

                onEdit: () => manager.navigateToEditReward(context, reward),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildAddRewardButton(BuildContext context, RewardManager manager) {
    return FloatingActionButton(
      onPressed: () => manager.navigateToAddReward(context),
      tooltip: 'Ajouter une récompense',
      child: const Icon(Icons.add),
    );
  }
   void _showDeleteDialog(BuildContext context, RewardManager manager, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reward'),
        content: const Text('Are you sure you want to delete this reward?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              manager.deleteReward(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
