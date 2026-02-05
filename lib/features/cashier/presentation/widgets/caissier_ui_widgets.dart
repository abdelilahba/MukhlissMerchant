import 'package:flutter/material.dart';

/// Widget affichant le logo de l'application.
///
/// Utilisé comme placeholder quand le scanner n'est pas actif.
class AppLogoSection extends StatelessWidget {
  /// Chemin de l'image du logo
  final String imagePath;

  /// Crée une section logo.
  const AppLogoSection({
    super.key,

    this.imagePath = 'assets/images/lastpicture.jpeg',

  });

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF9FAFB),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 64,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Widget pour afficher un toast de succès pour les récompenses.
class RewardsSuccessToast extends StatelessWidget {
  /// Points après la réclamation
  final int totalPoints;

  /// Callback pour fermer le toast
  final VoidCallback? onClose;

  /// Crée un toast de succès.
  const RewardsSuccessToast({
    super.key,
    required this.totalPoints,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Récompenses réclamées !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nouveau solde: $totalPoints pts',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

/// État initial de l'interface caissier (prêt à scanner).
class CaissierReadyState extends StatelessWidget {
  /// Contenu à afficher
  final Widget child;

  /// Crée un état prêt.
  const CaissierReadyState({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}
