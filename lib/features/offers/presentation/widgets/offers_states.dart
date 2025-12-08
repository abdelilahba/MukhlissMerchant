import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// États visuels pour l'écran des offres.
///
/// Contient:
/// - [OffersLoadingState]: État de chargement
/// - [OffersEmptyState]: État vide

/// État de chargement des offres.
class OffersLoadingState extends StatelessWidget {
  /// Animation de fade (optionnelle)
  final Animation<double>? fadeAnimation;

  /// Animation de slide (optionnelle)
  final Animation<Offset>? slideAnimation;

  /// Crée un état de chargement.
  const OffersLoadingState({
    super.key,
    this.fadeAnimation,
    this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chargementoffres,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
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

/// État vide (aucune offre).
class OffersEmptyState extends StatelessWidget {
  /// Manager des offres
  final OfferManager manager;

  /// Crée un état vide.
  const OffersEmptyState({
    super.key,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.aucunoffre,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              l10n.commencezparcree,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => manager.navigateToAddOffer(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: Text(
              l10n.creeoffre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
