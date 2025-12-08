/// Widget d'état de chargement pour le module Caissier.
///
/// Affiche un indicateur de chargement avec message optionnel
/// et animation.
library;

import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/config/app_config.dart';

/// Widget affichant un état de chargement.
///
/// Utilisé pendant les opérations asynchrones comme:
/// - Chargement des données client
/// - Traitement d'une transaction
/// - Récupération des récompenses
///
/// ### Exemple:
/// ```dart
/// if (isLoading) {
///   return const CaissierLoadingState();
/// }
/// ```
class CaissierLoadingState extends StatelessWidget {
  /// Message à afficher sous l'indicateur
  final String? message;

  /// Taille de l'indicateur
  final double size;

  /// Couleur de l'indicateur (optionnel)
  final Color? color;

  /// Crée un widget de chargement.
  ///
  /// [message] - Texte optionnel sous l'indicateur
  /// [size] - Taille de l'indicateur (défaut: 50)
  /// [color] - Couleur personnalisée
  const CaissierLoadingState({
    super.key,
    this.message,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicateur de chargement
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),

          // Message optionnel
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de chargement avec animation pulsante.
///
/// Plus visuel que [CaissierLoadingState] simple.
class CaissierPulsingLoader extends StatefulWidget {
  /// Message à afficher
  final String? message;

  /// Crée un loader pulsant.
  const CaissierPulsingLoader({
    super.key,
    this.message,
  });

  @override
  State<CaissierPulsingLoader> createState() => _CaissierPulsingLoaderState();
}

class _CaissierPulsingLoaderState extends State<CaissierPulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animé
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: Icon(
                  Icons.storefront,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Indicateur
          const CircularProgressIndicator(),

          // Message
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour affichage de chargement d'image.
class ImageLoadingPlaceholder extends StatelessWidget {
  /// Largeur du placeholder
  final double? width;

  /// Hauteur du placeholder
  final double? height;

  /// Border radius
  final double borderRadius;

  /// Crée un placeholder de chargement d'image.
  const ImageLoadingPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Widget pour affichage d'erreur de chargement d'image.
class ImageErrorPlaceholder extends StatelessWidget {
  /// Largeur du placeholder
  final double? width;

  /// Hauteur du placeholder
  final double? height;

  /// Icône à afficher
  final IconData icon;

  /// Taille de l'icône
  final double iconSize;

  /// Crée un placeholder d'erreur d'image.
  const ImageErrorPlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.broken_image_outlined,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
