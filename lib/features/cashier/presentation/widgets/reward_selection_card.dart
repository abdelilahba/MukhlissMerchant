import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Widget pour afficher une carte de récompense moderne.
///
/// Affiche:
/// - Checkbox de sélection
/// - Nom de la récompense
/// - Points requis
/// - Indicateur de disponibilité
class RewardSelectionCard extends StatelessWidget {
  /// La récompense à afficher
  final Reward reward;

  /// Si le client peut se permettre cette récompense
  final bool canAfford;

  /// Si la récompense est sélectionnée
  final bool isSelected;

  /// Points actuels du client
  final int clientPoints;

  /// Callback quand on tape sur la carte
  final VoidCallback? onTap;

  /// Crée une carte de sélection de récompense.
  const RewardSelectionCard({
    super.key,
    required this.reward,
    required this.canAfford,
    required this.isSelected,
    required this.clientPoints,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: const Color(0xFF6366F1), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canAfford ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildCheckbox(),
                const SizedBox(width: 16),
                Expanded(child: _buildContent(l10n)),
                _buildPointsBadge(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: canAfford ? const Color(0xFF6366F1) : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reward.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: canAfford ? const Color(0xFF1F2937) : Colors.grey.shade500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (!canAfford) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              // TODO: Add 'manque' to AppLocalizations
              'Manque ${reward.requiredPoints - clientPoints} ${l10n.pts}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPointsBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: canAfford
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              )
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${reward.requiredPoints}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            l10n.pts,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
