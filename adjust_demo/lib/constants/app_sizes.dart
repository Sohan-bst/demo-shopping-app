import 'package:flutter/widgets.dart';

/// Spacing, radius and sizing tokens used across the app.
///
/// Using a fixed scale keeps layouts visually consistent and makes global
/// spacing tweaks a one-line change.
class AppSizes {
  const AppSizes._();

  // ---- Spacing scale (4pt grid) -----------------------------------------
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ---- Corner radii ------------------------------------------------------
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // ---- Component sizing --------------------------------------------------
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double avatarSm = 40;
  static const double avatarLg = 88;

  // ---- Page constraints --------------------------------------------------
  /// Maximum content width so the layout stays readable on tablets/desktop.
  static const double maxContentWidth = 560;
  static const double productGridMaxExtent = 220;
}

/// Reusable [SizedBox] gaps to keep column/row spacing terse and consistent.
class Gaps {
  const Gaps._();

  static const SizedBox h4 = SizedBox(height: AppSizes.xs);
  static const SizedBox h8 = SizedBox(height: AppSizes.sm);
  static const SizedBox h12 = SizedBox(height: AppSizes.md);
  static const SizedBox h16 = SizedBox(height: AppSizes.lg);
  static const SizedBox h24 = SizedBox(height: AppSizes.xl);
  static const SizedBox h32 = SizedBox(height: AppSizes.xxl);
  static const SizedBox h48 = SizedBox(height: AppSizes.xxxl);

  static const SizedBox w4 = SizedBox(width: AppSizes.xs);
  static const SizedBox w8 = SizedBox(width: AppSizes.sm);
  static const SizedBox w12 = SizedBox(width: AppSizes.md);
  static const SizedBox w16 = SizedBox(width: AppSizes.lg);
  static const SizedBox w24 = SizedBox(width: AppSizes.xl);
}
