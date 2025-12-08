import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/managers/reward_manager.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// États visuels pour l'écran des récompenses.
///
/// Contient:
/// - [RewardsLoadingState]: État de chargement
/// - [RewardsErrorState]: État d'erreur
/// - [RewardsEmptyState]: État vide
/// - [RewardsNoResultsState]: Aucun résultat de recherche

/// État de chargement des récompenses.
class RewardsLoadingState extends StatelessWidget {
  /// Animation de fade (optionnelle)
  final Animation<double>? fadeAnimation;

  /// Crée un état de chargement.
  const RewardsLoadingState({super.key, this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.chargementdesrecompences,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (fadeAnimation != null) {
      return FadeTransition(opacity: fadeAnimation!, child: content);
    }
    return content;
  }
}

/// État d'erreur des récompenses.
class RewardsErrorState extends StatelessWidget {
  /// Message d'erreur
  final String message;

  /// Callback de réessai
  final VoidCallback? onRetry;

  /// Crée un état d'erreur.
  const RewardsErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.oups,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.ressayer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// État vide (aucune récompense).
class RewardsEmptyState extends StatelessWidget {
  /// Manager des récompenses
  final RewardManager manager;

  /// Animation de fade (optionnelle)
  final Animation<double>? fadeAnimation;

  /// Animation de slide (optionnelle)
  final Animation<Offset>? slideAnimation;

  /// Crée un état vide.
  const RewardsEmptyState({
    super.key,
    required this.manager,
    this.fadeAnimation,
    this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget content = Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.purple.shade100],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 64,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.aucunerecompence,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.commencezparcreerecompence,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => manager.navigateToAddReward(context),
              icon: const Icon(Icons.add_rounded, size: 24),
              label: Text(
                l10n.creerecompence,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (slideAnimation != null) {
      content = SlideTransition(position: slideAnimation!, child: content);
    }
    if (fadeAnimation != null) {
      content = FadeTransition(opacity: fadeAnimation!, child: content);
    }

    return content;
  }
}

/// État "aucun résultat" de recherche.
class RewardsNoResultsState extends StatelessWidget {
  /// Manager des récompenses
  final RewardManager manager;

  /// Callback pour effacer la recherche
  final VoidCallback? onClearSearch;

  /// Crée un état "aucun résultat".
  const RewardsNoResultsState({
    super.key,
    required this.manager,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.amber.shade100],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun résultat', // TODO: Add l10n.aucunresultat
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune récompense trouvée', // TODO: Add l10n.aucunerecompencetrouve
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onClearSearch != null)
                  OutlinedButton.icon(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text(
                        'Effacer'), // TODO: Add l10n.effacerrecherche
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => manager.navigateToAddReward(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.creerecompence),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
