import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

/// The app's wordmark: a rounded gradient tile with a shopping-bag glyph,
/// optionally followed by the brand name.
///
/// Reused on the splash and auth screens so branding stays consistent.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 72,
    this.showName = true,
  });

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandSeed, AppColors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandSeed.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.shopping_bag_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );

    if (!showName) return tile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Gaps.h16,
        Text(
          'Nova Store',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
