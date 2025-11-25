import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';

import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class RewardSelectionScreen extends StatefulWidget {
  final String clientId;
  final String magasinId;
  final int clientPoints;
  final VoidCallback? onRewardsCompleted;
  final Function(int pointsRestants)? onRewardClaimed;

  const RewardSelectionScreen({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientPoints,
    this.onRewardsCompleted,
    this.onRewardClaimed,
  });

  @override
  State<RewardSelectionScreen> createState() => _RewardSelectionScreenState();
}

class _RewardSelectionScreenState extends State<RewardSelectionScreen>
    with TickerProviderStateMixin {
  final CaissierCubit _cubit = getIt<CaissierCubit>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Reward> _selectedRewards = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _cubit.loadClientRewards(
      clientId: widget.clientId,
      magasinId: widget.magasinId,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            return _buildLoadingScreen();
          } else if (state is CaissierError) {
            return _buildErrorScreen(state.message);
          }
          return _buildLoadingScreen();
        },
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE pour afficher le toast de succès
  void _showRewardSuccessToast({
    required int pointsRestants,
    required int pointsDeduits,
  }) {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Félicitations !',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${"Récompense échangée avec succès"}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${"Points restants"}: $pointsRestants ${l10n.pts ?? "pts"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
        elevation: 12,
      ),
    );
  }

  // Dans recompenses_disponibles_screen.dart
  // Remplacer la méthode _handleState (lignes 131-165)

  void _handleState(BuildContext context, CaissierState state) async {
    if (state is RecompenseReclamee) {
      // ✅ CORRECTION : Clarifier la signification de state.pointsDeduits
      // state.pointsDeduits contient les points RESTANTS après l'échange
      final pointsRestantsApresEchange = state.pointsDeduits;
      final pointsUtilisesPourRecompense =
          widget.clientPoints - state.pointsDeduits;

      // ✅ Afficher le toast de succès avec les bonnes valeurs


      // ✅ Si callback fourni, l'utiliser avec les points restants
      if (widget.onRewardClaimed != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onRewardClaimed!(pointsRestantsApresEchange);
      }

      // ✅ Appeler onRewardsCompleted si fourni
      if (widget.onRewardsCompleted != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onRewardsCompleted!();
      }

      // ✅ Fermer l'écran après un délai
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else if (state is CaissierError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF87171),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _confirmMultipleClaims() async {
    final L10n = AppLocalizations.of(context);
    final totalCost = _selectedRewards.fold(
      0,
      (sum, reward) => sum + reward.requiredPoints,
    );

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 60,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    L10n.confirmerechange,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ..._selectedRewards.map(
                          (reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reward.name,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${reward.requiredPoints} ${L10n.pts}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(height: 1, color: Colors.grey[300]),
                        const SizedBox(height: 6),

                        _buildSummaryRow(
                          L10n.total,
                          '$totalCost ${L10n.pts}',
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 4),
                        _buildSummaryRow(
                          L10n.newsolde,
                          '${widget.clientPoints - totalCost} ${L10n.pts}',
                          const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            L10n.annuler,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            L10n.confirmer,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (confirm == true) {
      for (final reward in _selectedRewards) {
        _cubit.claimReward(
          clientId: widget.clientId,
          magasinId: widget.magasinId,
          rewardId: reward.id,
          pointsRequired: reward.requiredPoints,
        );
      }
    }
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeButton(int clientPoints) {
    final totalCost = _selectedRewards.fold(
      0,
      (sum, reward) => sum + reward.requiredPoints,
    );
    final canAfford = clientPoints >= totalCost;

    return AnimatedScale(
      scale: _selectedRewards.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        onPressed: canAfford ? () => _confirmMultipleClaims() : null,
        backgroundColor:
            canAfford
                ? const Color.fromARGB(255, 60, 228, 116)
                : Colors.grey.shade400,
        elevation: canAfford ? 8 : 2,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildScaffold(List<Reward> rewards, int clientPoints) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton:
          _selectedRewards.isNotEmpty
              ? _buildExchangeButton(clientPoints)
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child:
                    rewards.isEmpty
                        ? _buildEmptyState()
                        : _buildRewardsList(rewards, clientPoints),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    final L10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              L10n.chargementdesrecompences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    final L10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: Color(0xFFF87171),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    L10n.oups,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed:
                        () => _cubit.loadClientRewards(
                          clientId: widget.clientId,
                          magasinId: widget.magasinId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      L10n.ressayer,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final L10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              L10n.aucunerecompence,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              L10n.revenez,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(List<Reward> rewards, int clientPoints) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final disponible = clientPoints >= reward.requiredPoints;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildModernRewardCard(
            reward,
            disponible,
            index,
            clientPoints,
          ),
        );
      },
    );
  }

  Widget _buildModernRewardCard(
    Reward reward,
    bool disponible,
    int index,
    int clientPoints,
  ) {
    final L10n = AppLocalizations.of(context);
    final isSelected = _isRewardSelected(reward);
    final canAfford = clientPoints >= reward.requiredPoints;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            isSelected
                ? Border.all(color: const Color(0xFF6366F1), width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canAfford ? () => _toggleRewardSelection(reward) : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          canAfford
                              ? const Color(0xFF6366F1)
                              : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Hero(
                  tag: 'reward_${reward.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient:
                          canAfford
                              ? const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              )
                              : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ],
                              ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              canAfford ? Colors.grey[800] : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        L10n.descriptionnondisponible,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!canAfford) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${L10n.ilvousmanque} ${reward.requiredPoints - clientPoints} ${L10n.pts}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF87171),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            canAfford
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
                                )
                                : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500,
                                  ],
                                ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${reward.requiredPoints}${L10n.pts}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (canAfford) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          L10n.disponible,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleRewardSelection(Reward reward) {
    setState(() {
      if (_selectedRewards.contains(reward)) {
        _selectedRewards.remove(reward);
      } else {
        _selectedRewards.add(reward);
      }
    });
  }

  bool _isRewardSelected(Reward reward) {
    return _selectedRewards.contains(reward);
  }
}
