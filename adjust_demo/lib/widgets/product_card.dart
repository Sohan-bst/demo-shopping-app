import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/snackbar.dart';
import 'product_image.dart';
import 'rating_stars.dart';

/// A tappable product card showing the placeholder image, name, rating and
/// price, with an out-of-stock / low-stock badge overlay.
///
/// It fills the width of its parent, so it works both inside a
/// [GridView]/[SliverGrid] cell and inside a fixed-width box on a horizontal
/// rail. When [showWishlist] is true (the default) it renders a heart that
/// reads and toggles the [WishlistProvider] itself, so callers don't have to
/// wire it up at every use site.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showWishlist = true,
  });

  final Product product;
  final VoidCallback onTap;
  final bool showWishlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isWishlisted = showWishlist &&
        context.select<WishlistProvider, bool>((w) => w.contains(product));

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Image + overlays ------------------------------------------
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: product),
                  if (!product.inStock)
                    _Badge(
                      label: 'Out of stock',
                      color: scheme.surfaceContainerHighest,
                      textColor: scheme.onSurfaceVariant,
                    )
                  else if (product.isLowStock)
                    _Badge(
                      label: 'Only ${product.stock} left',
                      color: AppColors.warning,
                      textColor: Colors.white,
                    ),
                  if (showWishlist)
                    Positioned(
                      top: AppSizes.xs,
                      right: AppSizes.xs,
                      child: _WishlistButton(
                        active: isWishlisted,
                        onPressed: () {
                          final nowSaved = context
                              .read<WishlistProvider>()
                              .toggle(product);
                          AppSnackbar.info(
                            context,
                            nowSaved
                                ? AppStrings.addedToWishlist
                                : AppStrings.removedFromWishlist,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ---- Details ---------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Gaps.h4,
                  RatingStars(
                    rating: product.rating,
                    size: 14,
                  ),
                  Gaps.h8,
                  Text(
                    Formatters.price(product.price),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill badge shown over the product image (stock states).
class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSizes.sm,
      left: AppSizes.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A circular, frosted wishlist heart toggle overlaid on the product image.
class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: AppSizes.iconSm,
            color: active
                ? AppColors.danger
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
