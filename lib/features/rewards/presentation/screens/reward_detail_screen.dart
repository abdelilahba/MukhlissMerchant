import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_state.dart';

class RewardDetailScreen extends StatelessWidget {
  const RewardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la récompense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<RewardCubit>().returnToList(),
        ),
      ),
      body: BlocBuilder<RewardCubit, RewardState>(
        builder: (context, state) {
          if (state is RewardDetailLoaded) {
            final reward = state.reward;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reward.imagePath != null)
                    Center(
                      child: Image.network(
                        reward.imagePath!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    reward.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${reward.requiredPoints} points requis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Text(
                  //   reward.description,
                  //   style: Theme.of(context).textTheme.bodyLarge,
                  // ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}