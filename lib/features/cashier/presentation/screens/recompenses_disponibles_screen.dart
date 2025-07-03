import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/success_screen.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';


/// et permet au caissier d'en sélectionner une à réclamer.
class RewardSelectionScreen extends StatefulWidget {
  final String clientId;
  final String magasinId;
  final int clientPoints;

  const RewardSelectionScreen({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientPoints,
  });

  @override
  State<RewardSelectionScreen> createState() => _RewardSelectionScreenState();
}

class _RewardSelectionScreenState extends State<RewardSelectionScreen> {
  final CaissierCubit _cubit = getIt<CaissierCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadClientRewards(
      clientId: widget.clientId,
      magasinId: widget.magasinId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CaissierCubit, CaissierState>(
        listener: _handleState,
        builder: (context, state) {
          if (state is RecompensesChargees) {
            return _buildScaffold(state.rewards, state.clientPoints);
          } else if (state is CaissierLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is CaissierError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          return const Scaffold();
        },
      ),
    );
  }

  Widget _buildScaffold(List<Reward> rewards, int clientPoints) {
    return Scaffold(
      appBar: AppBar(title: const Text('Récompenses disponibles')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final r = rewards[index];
          final disponible = clientPoints >= r.requiredPoints;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text(r.name ),
              subtitle: Text('${r.requiredPoints} pts'),
              trailing: disponible
                  ? const Icon(Icons.chevron_right)
                  : const Icon(Icons.lock, color: Colors.grey),
              onTap: disponible ? () => _confirmClaim(r) : null,
            ),
          );
        },
      ),
    );
  }

  void _confirmClaim(Reward reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la récompense'),
        content: Text('Utiliser ${reward.requiredPoints} pts pour "${reward.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
        ],
      ),
    );

    if (confirm == true) {
      _cubit.claimReward(
        clientId: widget.clientId,
        magasinId: widget.magasinId,
        rewardId: reward.id,
        pointsRequired: reward.requiredPoints,
      );
    }
  }

  void _handleState(BuildContext context, CaissierState state) async {
    if (state is RecompenseReclamee) {
      // Après succès, affiche l'écran de félicitations avec points dépensés
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FelicitationScreen(
            pointsGagnes: widget.clientPoints - 0, // placeholder
            soldeRestant: null,
          ),
        ),
      );
      // ignore: use_build_context_synchronously
      if (mounted) Navigator.pop(context, true);
    } else if (state is CaissierError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }
}
