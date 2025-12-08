import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/recompenses_disponibles_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Widget conteneur pour la sélection et réclamation de récompenses.
///
/// Affiche:
/// - En-tête avec bouton retour et points du client
/// - Contenu avec la liste des récompenses disponibles
///
/// ### Exemple:
/// ```dart
/// RewardsContainerWidget(
///   clientId: '123',
///   magasinId: '456',
///   clientPoints: 150,
///   onBackPressed: () => resetState(),
///   onRewardsCompleted: () => handleComplete(),
///   onRewardClaimed: (points) => updatePoints(points),
/// )
/// ```
class RewardsContainerWidget extends StatelessWidget {
  /// ID du client
  final String clientId;

  /// ID du magasin
  final String magasinId;

  /// Points actuels du client
  final int clientPoints;

  /// Callback quand le bouton retour est pressé
  final VoidCallback onBackPressed;

  /// Callback quand toutes les récompenses sont traitées
  final VoidCallback? onRewardsCompleted;

  /// Callback quand une récompense est réclamée
  final void Function(int pointsRestants)? onRewardClaimed;

  /// Crée un conteneur de récompenses.
  const RewardsContainerWidget({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientPoints,
    required this.onBackPressed,
    this.onRewardsCompleted,
    this.onRewardClaimed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec bouton retour
          _buildHeader(context, l10n),

          // RewardSelectionScreen intégré
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: RewardSelectionScreen(
                clientId: clientId,
                magasinId: magasinId,
                clientPoints: clientPoints,
                onRewardsCompleted: onRewardsCompleted,
                onRewardClaimed: (pointsRestants) {
                  AppLogger.info(
                    '🎉 Récompense réclamée ! Points restants: $pointsRestants',
                    tag: 'Rewards',
                  );
                  onRewardClaimed?.call(pointsRestants);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded),
            ),
            onPressed: onBackPressed,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.soldepoints,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),

          // Badge des points
          _buildPointsBadge(l10n),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$clientPoints ${l10n.pts}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
