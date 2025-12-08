import 'dart:async';

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
  final Function(bool hasSelectedRewards)? onBackPressed;
  const RewardSelectionScreen({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientPoints,
    this.onRewardsCompleted,
    this.onRewardClaimed,
    this.onBackPressed,
  });

  @override
  State<RewardSelectionScreen> createState() => _RewardSelectionScreenState();
}

class _RewardSelectionScreenState extends State<RewardSelectionScreen>
    with TickerProviderStateMixin {
  bool _hasSelectedRewards = false;
  final CaissierCubit _cubit = getIt<CaissierCubit>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Reward> _selectedRewards = [];
  int _totalRewardsToClaim = 0;
  int _rewardsClaimedCount = 0;
  int _finalPointsAfterAllClaims = 0;

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

  // Données mises en cache pour éviter les clignotements/écrans noirs
  List<Reward>? _cachedRewards;
  int? _cachedPoints;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CaissierCubit, CaissierState>(
        listener: (context, state) {
          // Mettre à jour le cache quand les données arrivent
          if (state is RecompensesChargees) {
            setState(() {
              _cachedRewards = state.rewards;
              _cachedPoints = state.clientPoints;
            });
          } else if (state is CaissierError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // 1. Si on a des données en cache, on les affiche TOUJOURS
          // Cela empêche l'écran de devenir noir ou de montrer un loader intempestif
          if (_cachedRewards != null && _cachedPoints != null) {
            return _buildScaffold(_cachedRewards!, _cachedPoints!);
          }

          // 2. Sinon, on gère les états initiaux
          if (state is RecompensesChargees) {
            // Normalement géré par le cache, mais au cas où
            _cachedRewards = state.rewards;
            _cachedPoints = state.clientPoints;
            return _buildScaffold(state.rewards, state.clientPoints);
          } else if (state is CaissierLoading) {
            return _buildLoadingScreen();
          } else if (state is CaissierError) {
            return _buildErrorScreen(state.message);
          }

          // 3. Par défaut (chargement initial)
          return _buildLoadingScreen();
        },
      ),
    );
  }

  // Plus besoin de _handleState séparé, tout est dans le listener du BlocConsumer

  void _confirmMultipleClaims() async {
    final L10n = AppLocalizations.of(context);
    final totalCost = _selectedRewards.fold(
      0,
      (sum, reward) => sum + reward.requiredPoints,
    );

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Réduit de 20 à 16
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20, // Réduit de 15 à 20
          vertical: 80, // Augmenté de 60 à 80 pour rendre plus petit
        ),
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 350), // Réduit de 400 à 350
          padding: const EdgeInsets.all(16), // Réduit de 20 à 16
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, // Réduit de 50 à 40
                height: 40, // Réduit de 50 à 40
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(20), // Réduit de 25 à 20
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 20, // Réduit de 24 à 20
                ),
              ),
              const SizedBox(height: 8), // Réduit de 12 à 8

              Text(
                L10n.confirmerechange,
                style: TextStyle(
                  fontSize: 14, // Réduit de 16 à 14
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Reste à 8

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
      _totalRewardsToClaim = _selectedRewards.length;
      _rewardsClaimedCount = 0;
      _finalPointsAfterAllClaims = widget.clientPoints - totalCost;

      // ✅ AFFICHER UN DIALOGUE DE CHARGEMENT au lieu de l'écran noir
      _showLoadingDialogAndClaim();
    }
  }

  /// Affiche un dialogue de chargement élégant pendant la réclamation
  Future<void> _showLoadingDialogAndClaim() async {
    // Afficher le dialogue
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Réclamation en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedRewards.length} récompense${_selectedRewards.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Réclamer les récompenses
      await _claimRewardsSequentially();
    } finally {
      // 1. Fermer le dialogue de chargement (TOUJOURS)
      // ✅ Utiliser le MÊME navigator que celui utilisé dans showDialog (ligne 297-298)
      // showDialog utilise context (navigator local), donc on doit utiliser le navigator local ici aussi
      if (mounted) {
        Navigator.of(context).pop(); // ⚡ Ferme le dialogue
      }

      // 2. Petit délai pour éviter les conflits de navigation
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Fermer l'écran des récompenses
      if (mounted) {
        Navigator.of(context).pop(true); // ⚡ Ferme l'écran
      }
    }
  }

  /// ⚡ VERSION ULTRA-RAPIDE : Réclamation en PARALLÈLE de toutes les récompenses
  Future<void> _claimRewardsSequentially() async {
    final totalCost =
        _selectedRewards.fold(0, (sum, reward) => sum + reward.requiredPoints);
    final expectedFinalPoints = widget.clientPoints - totalCost;

    try {
      // ⚡ RÉCLAMER TOUTES LES RÉCOMPENSES EN PARALLÈLE
      final results = await Future.wait(
        _selectedRewards.map((reward) => _claimSingleReward(reward)),
        eagerError: false,
      );
      // Compter les succès et calculer les points réellement dépensés
      int successCount = 0;
      int pointsSpent = 0;
      List<String> failedRewards = [];

      for (int i = 0; i < results.length; i++) {
        if (results[i] == true) {
          successCount++;
          pointsSpent += _selectedRewards[i].requiredPoints;
        } else {
          failedRewards.add(_selectedRewards[i].name);
        }
      }

      // ⚡ CALCUL LOCAL - Plus fiable et plus rapide que l'appel réseau
      // (évite les problèmes de cache et de latence)
      final realFinalPoints = widget.clientPoints - pointsSpent;

      // Message si des échecs
      if (failedRewards.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount/${_selectedRewards.length} récompenses réclamées',
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor:
                failedRewards.isEmpty ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      // Callback avec les points réels calculés
      if (widget.onRewardClaimed != null) {
        widget.onRewardClaimed!(realFinalPoints);
      }
    } catch (e) {
      // Fallback en cas d'erreur
      if (widget.onRewardClaimed != null) {
        widget.onRewardClaimed!(expectedFinalPoints);
      }
    }
  }

  /// ⚡ Réclame UNE SEULE récompense de manière rapide
  /// Retourne true si succès, false si échec
  Future<bool> _claimSingleReward(Reward reward) async {
    try {
      // Completer pour attendre la réponse
      final completer = Completer<bool>();

      // Écouter la réponse du cubit
      final subscription = _cubit.stream.listen((state) {
        if (state is RecompenseReclamee && !completer.isCompleted) {
          completer.complete(true);
        } else if (state is CaissierError && !completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Lancer la réclamation
      _cubit.claimReward(
        clientId: widget.clientId,
        magasinId: widget.magasinId,
        rewardId: reward.id,
        pointsRequired: reward.requiredPoints,
      );

      // Attendre la réponse avec timeout de 5 secondes
      final success = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      subscription.cancel();
      return success;
    } catch (e) {
      return false;
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
        backgroundColor: canAfford
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
      floatingActionButton: _selectedRewards.isNotEmpty
          ? _buildExchangeButton(clientPoints)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: rewards.isEmpty
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
                    onPressed: () => _cubit.loadClientRewards(
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
        border: isSelected
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
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: canAfford
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
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
                      gradient: canAfford
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
                        gradient: canAfford
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
      _hasSelectedRewards =
          _selectedRewards.isNotEmpty; // ✅ METTRE À JOUR LE TRACKER
    });
  }

  bool _isRewardSelected(Reward reward) {
    return _selectedRewards.contains(reward);
  }
}
