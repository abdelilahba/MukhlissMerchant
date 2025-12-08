import 'package:flutter/material.dart';

/// Widget pour afficher la section du scanner avec un header.
///
/// Contient un bouton retour et le contenu principal (scanner ou logo).
class ScannerSectionWidget extends StatelessWidget {
  /// Callback quand on appuie sur le bouton retour
  final VoidCallback onBackPressed;

  /// Widget à afficher dans le contenu principal
  final Widget content;

  /// Crée une section scanner.
  const ScannerSectionWidget({
    super.key,
    required this.onBackPressed,
    required this.content,
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
      child: Column(
        children: [
          // Header simplifié avec uniquement le bouton retour
          Container(
            height: 60,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBackPressed,
                ),
              ],
            ),
          ),
          // Contenu principal
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Widget wrapper pour un contenu avec décoration standard.
class StandardCardWidget extends StatelessWidget {
  /// Contenu du widget
  final Widget child;

  /// Border radius
  final double borderRadius;

  /// Crée une carte standard.
  const StandardCardWidget({
    super.key,
    required this.child,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
