/// Widget pour afficher le logo et nom du magasin.
///
/// Utilisé dans l'écran principal caissier pour
/// identifier le magasin courant.
library;

import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/widgets/loading_states.dart';

/// Widget affichant le logo du magasin.
///
/// Affiche:
/// - Logo depuis URL réseau
/// - Placeholder pendant chargement
/// - Icône par défaut si erreur
/// - Nom du magasin
///
/// ### Exemple:
/// ```dart
/// MagasinLogoWidget(
///   magasin: currentMagasin,
///   size: MagasinLogoSize.medium,
/// )
/// ```
class MagasinLogoWidget extends StatelessWidget {
  /// Modèle du magasin
  final MagasinModel magasin;

  /// Taille du logo
  final MagasinLogoSize size;

  /// Afficher le nom sous le logo
  final bool showName;

  /// Padding autour du widget
  final EdgeInsetsGeometry padding;

  /// Crée un widget de logo magasin.
  const MagasinLogoWidget({
    super.key,
    required this.magasin,
    this.size = MagasinLogoSize.medium,
    this.showName = true,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          // Logo
          Expanded(
            child: _buildLogo(),
          ),

          // Nom du magasin
          if (showName) ...[
            SizedBox(height: size.nameSpacing),
            _buildName(),
          ],
        ],
      ),
    );
  }

  /// Construit le logo du magasin.
  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.borderRadius),
      child: magasin.imageUrl.isNotEmpty
          ? Image.network(
              magasin.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return ImageLoadingPlaceholder(
                  width: size.logoSize,
                  height: size.logoSize,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultLogo();
              },
            )
          : _buildDefaultLogo(),
    );
  }

  /// Logo par défaut quand pas d'image.
  Widget _buildDefaultLogo() {
    return Container(
      width: size.logoSize,
      height: size.logoSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.borderRadius),
      ),
      child: Icon(
        Icons.storefront,
        size: size.iconSize,
        color: Colors.white,
      ),
    );
  }

  /// Construit le nom du magasin.
  Widget _buildName() {
    return SizedBox(
      height: size.nameHeight,
      child: Text(
        magasin.nomEnseigne,
        style: TextStyle(
          fontSize: size.fontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Énumération des tailles de logo disponibles.
enum MagasinLogoSize {
  /// Petit logo (pour listes)
  small(
    logoSize: 40,
    iconSize: 24,
    fontSize: 12,
    nameHeight: 16,
    nameSpacing: 8,
    borderRadius: 8,
  ),

  /// Logo moyen (pour cards)
  medium(
    logoSize: 80,
    iconSize: 40,
    fontSize: 16,
    nameHeight: 22,
    nameSpacing: 12,
    borderRadius: 12,
  ),

  /// Grand logo (pour écran principal)
  large(
    logoSize: 120,
    iconSize: 60,
    fontSize: 20,
    nameHeight: 28,
    nameSpacing: 16,
    borderRadius: 16,
  );

  /// Taille du logo en pixels
  final double logoSize;

  /// Taille de l'icône par défaut
  final double iconSize;

  /// Taille de la police du nom
  final double fontSize;

  /// Hauteur de la zone du nom
  final double nameHeight;

  /// Espacement entre logo et nom
  final double nameSpacing;

  /// Border radius du logo
  final double borderRadius;

  const MagasinLogoSize({
    required this.logoSize,
    required this.iconSize,
    required this.fontSize,
    required this.nameHeight,
    required this.nameSpacing,
    required this.borderRadius,
  });
}

/// Version compacte du logo pour les headers.
class MagasinLogoCompact extends StatelessWidget {
  /// Modèle du magasin
  final MagasinModel magasin;

  /// Taille du logo
  final double size;

  /// Crée une version compacte du logo.
  const MagasinLogoCompact({
    super.key,
    required this.magasin,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: magasin.imageUrl.isNotEmpty
          ? Image.network(
              magasin.imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefault(),
            )
          : _buildDefault(),
    );
  }

  Widget _buildDefault() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.storefront,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}
