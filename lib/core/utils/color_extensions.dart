/// Color extension to provide modern opacity methods.
/// 
/// Replaces deprecated `withOpacity` with `withValues` for better precision.
/// 
/// Usage:
/// ```dart
/// import 'package:mukhlissmagasin/core/utils/color_extensions.dart';
/// 
/// // Instead of color.withOpacity(0.5) use:
/// color.withAlpha50; // or
/// color.alpha(0.5);
/// ```
library;

import 'package:flutter/material.dart';

/// Extension on [Color] to provide non-deprecated opacity methods.
extension ColorOpacity on Color {
  /// Returns this color with the given opacity (0.0 to 1.0)
  /// 
  /// This is a drop-in replacement for the deprecated `withOpacity`.
  Color alpha(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withValues(alpha: opacity);
  }

  // ========== COMMON OPACITY PRESETS ==========
  
  /// Color with 5% opacity
  Color get alpha5 => withValues(alpha: 0.05);
  
  /// Color with 10% opacity
  Color get alpha10 => withValues(alpha: 0.1);
  
  /// Color with 15% opacity
  Color get alpha15 => withValues(alpha: 0.15);
  
  /// Color with 20% opacity
  Color get alpha20 => withValues(alpha: 0.2);
  
  /// Color with 25% opacity
  Color get alpha25 => withValues(alpha: 0.25);
  
  /// Color with 30% opacity
  Color get alpha30 => withValues(alpha: 0.3);
  
  /// Color with 40% opacity
  Color get alpha40 => withValues(alpha: 0.4);
  
  /// Color with 50% opacity
  Color get alpha50 => withValues(alpha: 0.5);
  
  /// Color with 60% opacity
  Color get alpha60 => withValues(alpha: 0.6);
  
  /// Color with 70% opacity
  Color get alpha70 => withValues(alpha: 0.7);
  
  /// Color with 80% opacity
  Color get alpha80 => withValues(alpha: 0.8);
  
  /// Color with 90% opacity
  Color get alpha90 => withValues(alpha: 0.9);
}
