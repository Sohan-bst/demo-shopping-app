import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/product.dart';
import '../../navigation/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';

/// The saved-items list (Wishlist).
///
/// Each row can be removed or moved to the cart (which removes it here and adds
/// it to the cart). Reads and mutates [WishlistProvider] / [CartProvider].
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final products = wishlist.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wishlist),
        actions: [
          if (!wishlist.isEmpty)
            TextButton(
              onPressed: () {
                wishlist.clear();
                AppSnackbar.info(context, 'Wishlist cleared');
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: products.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: AppStrings.emptyWishlistTitle,
              message: AppStrings.emptyWishlistMessage,
              actionLabel: AppStrings.continueShopping,
              onAction: () => context.goNamed(AppRoutes.nHome),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.lg),
              itemCount: products.length,
              separatorBuilder: (_, _) => Gaps.h12,
              itemBuilder: (context, i) => _WishlistLine(product: products[i]),
            ),
    );
  }
}

class _WishlistLine extends StatelessWidget {
  const _WishlistLine({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutes.nProduct,
          pathParameters: {'id': product.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: SizedBox(
                  height: 72,
                  width: 72,
                  child: ProductImage(product: product, iconScale: 0.5),
                ),
              ),
              Gaps.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Gaps.h4,
                    Text(
                      Formatters.price(product.price),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Gaps.h8,
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: product.inStock
                              ? () => _moveToCart(context)
                              : null,
                          icon: const Icon(Icons.add_shopping_cart_rounded,
                              size: AppSizes.iconSm),
                          label: Text(product.inStock
                              ? AppStrings.moveToCart
                              : AppStrings.outOfStock),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            context.read<WishlistProvider>().remove(product);
                            AppSnackbar.info(
                                context, AppStrings.removedFromWishlist);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveToCart(BuildContext context) {
    context.read<CartProvider>().add(product);
    context.read<WishlistProvider>().remove(product);
    AppSnackbar.success(context, AppStrings.addedToCart);
  }
}
