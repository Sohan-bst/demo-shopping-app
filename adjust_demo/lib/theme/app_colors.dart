import 'package:flutter/material.dart';

/// Brand color palette and semantic colors.
///
/// The Material 3 [ColorScheme] is seeded from [brandSeed]; these extra tokens
/// cover cases the generated scheme doesn't (e.g. rating gold, order statuses).
class AppColors {
  const AppColors._();

  /// Primary brand seed used to generate the Material 3 color schemes.
  static const Color brandSeed = Color(0xFF5B5BF0);

  /// Accent used for highlights and secondary CTAs.
  static const Color accent = Color(0xFF00C2A8);

  // ---- Semantic ----------------------------------------------------------
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE8A317);
  static const Color danger = Color(0xFFE5484D);
  static const Color rating = Color(0xFFF5A623);

  // ---- Order status ------------------------------------------------------
  static const Color statusDelivered = Color(0xFF2E9E5B);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusCancelled = Color(0xFFE5484D);

  /// Deterministic palette used to tint procedurally-drawn product images.
  static const List<Color> productSwatches = <Color>[
    Color(0xFF6C8EF5),
    Color(0xFF00C2A8),
    Color(0xFFF5A623),
    Color(0xFFEE6C8B),
    Color(0xFF9B6CF5),
    Color(0xFF4EC0B4),
    Color(0xFFF08A5D),
    Color(0xFF5B8DEF),
  ];
}
