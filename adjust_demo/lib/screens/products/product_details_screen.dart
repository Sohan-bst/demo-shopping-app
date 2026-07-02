import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../data/category_data.dart';
import '../../models/product.dart';
import '../../navigation/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/analytics/analytics_context.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_image.dart';
import '../../widgets/rating_stars.dart';

/// Full product detail view.
///
/// Shows a large placeholder image, name, category, rating, stock and
/// description, a "You may also like" rail, and a persistent bottom action bar
/// wired to the cart and wishlist providers (add to cart, buy now, favourite).
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fire a view_product event once when the screen opens.
    final product = context.read<ProductProvider>().byId(widget.productId);
    if (product != null) context.logViewProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();
    final product = provider.byId(widget.productId);

    // Guard against an unknown/stale id (e.g. deep link after data reset).
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Product not found',
          message: 'This item may no longer be available.',
          actionLabel: 'Back to store',
          onAction: () => context.go(AppRoutes.home),
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final category = CategoryData.byId(product.categoryId);
    final related = provider.relatedTo(product);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: AppStrings.share,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => AppSnackbar.info(context, AppStrings.shareInfo),
          ),
          _WishlistAction(product: product),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- Hero image ------------------------------------------------
          Hero(
            tag: 'product-${product.id}',
            child: AspectRatio(
              aspectRatio: 1.1,
              child: ProductImage(product: product, iconScale: 0.34),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Category + stock chips ------------------------------
                Row(
                  children: [
                    if (category != null)
                      _Pill(
                        icon: category.icon,
                        label: category.label,
                        color: category.color,
                      ),
                    const Spacer(),
                    _StockPill(product: product),
                  ],
                ),
                Gaps.h16,

                // ---- Name ------------------------------------------------
                Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Gaps.h8,

                // ---- Rating ----------------------------------------------
                RatingStars(
                  rating: product.rating,
                  ratingCount: product.ratingCount,
                  size: AppSizes.iconMd,
                ),
                Gaps.h16,

                // ---- Price -----------------------------------------------
                Text(
                  Formatters.price(product.price),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
                Gaps.h24,

                // ---- Description -----------------------------------------
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.h8,
                Text(
                  product.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ---- Related products --------------------------------------------
          if (related.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                0,
                AppSizes.lg,
                AppSizes.sm,
              ),
              child: Text(
                AppStrings.relatedProducts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  AppSizes.lg,
                ),
                itemCount: related.length,
                separatorBuilder: (_, _) => Gaps.w12,
                itemBuilder: (context, i) {
                  final r = related[i];
                  return SizedBox(
                    width: 168,
                    child: ProductCard(
                      product: r,
                      onTap: () => context.pushReplacementNamed(
                        AppRoutes.nProduct,
                        pathParameters: {'id': r.id},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),

      // ---- Sticky action bar ---------------------------------------------
      bottomNavigationBar: _ActionBar(product: product),
    );
  }
}

/// The app-bar wishlist toggle; reflects and mutates [WishlistProvider].
class _WishlistAction extends StatelessWidget {
  const _WishlistAction({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<WishlistProvider, bool>(
      (w) => w.contains(product),
    );
    return IconButton(
      tooltip: AppStrings.addToWishlist,
      icon: Icon(
        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: saved ? AppColors.danger : null,
      ),
      onPressed: () {
        final nowSaved = context.read<WishlistProvider>().toggle(product);
        AppSnackbar.info(
          context,
          nowSaved
              ? AppStrings.addedToWishlist
              : AppStrings.removedFromWishlist,
        );
      },
    );
  }
}

/// The persistent bottom bar with the primary purchase actions.
///
/// "Add to Cart" adds one unit (or shows the quantity already in the cart);
/// "Buy Now" adds and jumps straight to checkout. Both are disabled when the
/// product is out of stock.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = product.inStock;
    final inCart = context.select<CartProvider, int>(
      (c) => c.quantityOf(product),
    );

    void addToCart() {
      context.read<CartProvider>().add(product);
      AppSnackbar.success(context, AppStrings.addedToCart);
    }

    void buyNow() {
      final cart = context.read<CartProvider>();
      if (cart.quantityOf(product) == 0) cart.add(product);
      context.pushNamed(AppRoutes.nCheckout);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.sm,
          AppSizes.lg,
          AppSizes.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? addToCart : null,
                icon: const Icon(Icons.add_shopping_cart_rounded,
                    size: AppSizes.iconSm),
                label: Text(
                  inCart > 0 ? 'In cart ($inCart)' : AppStrings.addToCart,
                ),
              ),
            ),
            Gaps.w12,
            Expanded(
              child: FilledButton(
                onPressed: enabled ? buyNow : null,
                child: Text(
                  enabled ? AppStrings.buyNow : AppStrings.outOfStock,
                  style: TextStyle(
                    color: enabled ? null : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small tinted icon+label pill (used for the category tag).
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: color),
          Gaps.w4,
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// In-stock / low-stock / out-of-stock indicator.
class _StockPill extends StatelessWidget {
  const _StockPill({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color color, String label, IconData icon) = switch (product) {
      _ when !product.inStock => (
          theme.colorScheme.onSurfaceVariant,
          AppStrings.outOfStock,
          Icons.remove_shopping_cart_outlined,
        ),
      _ when product.isLowStock => (
          AppColors.warning,
          'Only ${product.stock} left',
          Icons.local_fire_department_rounded,
        ),
      _ => (AppColors.success, AppStrings.inStock, Icons.check_circle_rounded),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: color),
        Gaps.w4,
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
