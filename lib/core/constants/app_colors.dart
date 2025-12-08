import 'package:flutter/material.dart';

/// Application color constants.
/// 
/// Centralizes all color definitions for consistent theming.
/// 
/// Usage:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Error', style: TextStyle(color: AppColors.error))
/// ```
class AppColors {
  AppColors._(); // Private constructor

  // ========== BRAND COLORS ==========
  /// Primary brand color
  static const Color primary = Color(0xFF6366F1); // Indigo
  
  /// Secondary brand color
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  
  /// Accent/highlight color
  static const Color accent = Color(0xFF10B981); // Emerald

  // ========== STATUS COLORS ==========
  /// Success state color
  static const Color success = Color(0xFF10B981); // Emerald
  
  /// Warning state color
  static const Color warning = Color(0xFFF59E0B); // Amber
  
  /// Error/danger state color
  static const Color error = Color(0xFFEF4444); // Red
  
  /// Info state color
  static const Color info = Color(0xFF3B82F6); // Blue

  // ========== NEUTRAL COLORS ==========
  /// Background color (light mode)
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  
  /// Surface color (cards, dialogs)
  static const Color surface = Color(0xFFFFFFFF); // White
  
  /// Primary text color
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800
  
  /// Secondary text color
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  
  /// Disabled text color
  static const Color textDisabled = Color(0xFF94A3B8); // Slate-400
  
  /// Border color
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  
  /// Divider color
  static const Color divider = Color(0xFFE2E8F0); // Slate-200

  // ========== DARK MODE COLORS ==========
  /// Background color (dark mode)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900
  
  /// Surface color (dark mode)
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  
  /// Primary text color (dark mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate-50
  
  /// Secondary text color (dark mode)
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate-400

  // ========== GRADIENT COLORS ==========
  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== OPACITY HELPERS ==========
  /// Get color with opacity (use instead of deprecated withOpacity)
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Primary with 10% opacity
  static Color get primary10 => primary.withValues(alpha: 0.1);
  
  /// Primary with 20% opacity
  static Color get primary20 => primary.withValues(alpha: 0.2);
  
  /// Error with 10% opacity
  static Color get error10 => error.withValues(alpha: 0.1);
  
  /// Success with 10% opacity
  static Color get success10 => success.withValues(alpha: 0.1);
}

/// Commonly used text styles
class AppTextStyles {
  AppTextStyles._();

  /// Heading 1
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Heading 2
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Heading 3
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Small text
  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Caption text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
