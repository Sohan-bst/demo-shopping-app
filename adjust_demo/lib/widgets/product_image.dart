import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/product_visuals.dart';

/// A procedurally-drawn placeholder image for a product.
///
/// Renders a soft diagonal gradient (derived from the product's deterministic
/// swatch) with a large representative glyph, so the catalog looks lively
/// without shipping any binary image assets. Fills its parent; wrap in an
/// [AspectRatio] or size-constrained box as needed.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.iconScale = 0.42,
  });

  final Product product;

  /// Glyph size as a fraction of the shortest side.
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final base = ProductVisuals.colorFor(product);
    final icon = ProductVisuals.iconFor(product);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = constraints.biggest.shortestSide;
        final iconSize = (shortest.isFinite ? shortest : 96) * iconScale;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withValues(alpha: 0.22),
                base.withValues(alpha: 0.42),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: base,
            ),
          ),
        );
      },
    );
  }
}
