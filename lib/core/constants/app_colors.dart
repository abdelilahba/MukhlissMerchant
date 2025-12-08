import 'package:flutter/material.dart';

/// Couleurs de l'application centralisées
///
/// Définit la palette de couleurs complète pour:
/// - Consistance visuelle
/// - Theming facile
/// - Dark mode support
/// - Accessibilité
class AppColors {
  // Private constructor
  AppColors._();

  // ============================================
  // BRAND COLORS (Couleurs Marque)
  // ============================================

  /// Couleur principale de la marque
  static const Color primary = Color(0xFF2196F3); // Bleu

  /// Couleur principale variant (plus foncé)
  static const Color primaryDark = Color(0xFF1976D2);

  /// Couleur principale variant (plus clair)
  static const Color primaryLight = Color(0xFF64B5F6);

  /// Couleur secondaire (accent)
  static const Color secondary = Color(0xFFFFC107); // Jaune/Or

  /// Couleur secondaire variant
  static const Color secondaryDark = Color(0xFFFFA000);

  /// Couleur accent pour CTAs
  static const Color accent = Color(0xFF4CAF50); // Vert

  // ============================================
  // STATUS COLORS (Couleurs États)
  // ============================================

  /// Couleur succès
  static const Color success = Color(0xFF4CAF50); // Vert

  /// Couleur warning/attention
  static const Color warning = Color(0xFFFFC107); // Orange/Jaune

  /// Couleur erreur
  static const Color error = Color(0xFFF44336); // Rouge

  /// Couleur information
  static const Color info = Color(0xFF2196F3); // Bleu

  // ============================================
  // NEUTRAL COLORS (Couleurs Neutres)
  // ============================================

  /// Background principal (clair)
  static const Color background = Color(0xFFF5F5F5);

  /// Surface (cards, dialogs)
  static const Color surface = Color(0xFFFFFFFF);

  /// Texte principal
  static const Color textPrimary = Color(0xFF212121);

  /// Texte secondaire (moins important)
  static const Color textSecondary = Color(0xFF757575);

  /// Texte disabled
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Texte hint (placeholders)
  static const Color textHint = Color(0xFF9E9E9E);

  /// Dividers
  static const Color divider = Color(0xFFE0E0E0);

  /// Border des inputs
  static const Color border = Color(0xFFBDBDBD);

  // ============================================
  // DARK THEME COLORS
  // ============================================

  /// Background dark theme
  static const Color backgroundDark = Color(0xFF121212);

  /// Surface dark theme
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Texte principal dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Texte secondaire dark
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Gradient primary (pour backgrounds)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary,primaryDark],
  );

  /// Gradient success
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );

  /// Gradient accent
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF388E3C)],
  );

  // ============================================
  // SEMANTIC COLORS (Par Usage)
  // ============================================

  /// Couleur bouton primary
  static const Color buttonPrimary = primary;

  /// Couleur bouton secondary
  static const Color buttonSecondary = secondary;

  /// Couleur bouton disabled
  static const Color buttonDisabled = Color(0xFFE0E0E0);

  /// Couleur texte bouton
  static const Color buttonText = Colors.white;

  /// Couleur lien/link
  static const Color link = primary;

  /// Couleur icônes
  static const Color icon = textSecondary;

  /// Couleur icônes actives
  static const Color iconActive = primary;

  // ============================================
  // LOYALTY SPECIFIC COLORS
  // ============================================

  /// Couleur points de fidélité
  static const Color loyaltyPoints = Color(0xFFFFC107); // Or

  /// Couleur récompenses
  static const Color reward = Color(0xFFFF6F00); // Orange foncé

  /// Couleur solde
  static const Color balance = Color(0xFF4CAF50); // Vert

  /// Couleur badge premium
  static const Color premium = Color(0xFFFFD700); // Or brillant

  // ============================================
  // TRANSACTION COLORS
  // ============================================

  /// Couleur transaction crédit (+)
  static const Color transactionCredit = success;

  /// Couleur transaction débit (-)
  static const Color transactionDebit = error;

  /// Couleur transaction en attente
  static const Color transactionPending = warning;

  // ============================================
  // CHART & DATA VISUALIZATION
  // ============================================

  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Bleu
    Color(0xFFFFC107), // Jaune
    Color(0xFF4CAF50), // Vert
    Color(0xFFF44336), // Rouge
    Color(0xFF9C27B0), // Violet
    Color(0xFFFF9800), // Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFFCDDC39), // Lime
  ];

  // ============================================
  // SHADOWING & TRANSPARENCY
  // ============================================

  /// Ombre légère
  static const Color shadowLight = Color(0x0D000000);

  /// Ombre medium
  static const Color shadowMedium = Color(0x1A000000);

  /// Ombre forte
  static const Color shadowStrong = Color(0x33000000);

  /// Overlay (pour dialogs)
  static const Color overlay = Color(0x80000000);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Obtenir couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Obtenir couleur disabled d'une couleur
  static Color disabled(Color color) {
    return color.withOpacity(0.38);
  }

  /// Obtenir couleur hover d'une couleur
  static Color hover(Color color) {
    return color.withOpacity(0.08);
  }
}
