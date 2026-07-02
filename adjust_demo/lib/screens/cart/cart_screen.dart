import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/cart_item.dart';
import '../../navigation/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/price_summary.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';

/// The shopping cart (Cart tab).
///
/// Lists each cart line with a quantity stepper and remove action, shows the
/// running price breakdown, and offers "Continue Shopping" / "Checkout".
/// All mutations go straight to [CartProvider], which persists them.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.emptyCartTitle,
              message: AppStrings.emptyCartMessage,
              actionLabel: AppStrings.continueShopping,
              onAction: () => context.goNamed(AppRoutes.nHome),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => Gaps.h12,
                    itemBuilder: (context, i) =>
                        _CartLine(item: cart.items[i]),
                  ),
                ),
                _CartFooter(cart: cart),
              ],
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartProvider cart) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('This removes all items from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      cart.clear();
      AppSnackbar.info(context, AppStrings.cartCleared);
    }
  }
}

/// One cart row: image, name/price, quantity stepper and remove button.
class _CartLine extends StatelessWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.read<CartProvider>();
    final product = item.product;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: SizedBox(
                height: 72,
                width: 72,
                child: ProductImage(product: product, iconScale: 0.5),
              ),
            ),
            Gaps.w12,
            // Name + price + stepper
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
                      QuantityStepper(
                        quantity: item.quantity,
                        canIncrement:
                            item.quantity < product.stock,
                        onIncrement: () => cart.increment(product),
                        onDecrement: () => cart.decrement(product),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () {
                          cart.remove(product);
                          AppSnackbar.info(
                              context, AppStrings.removedFromCart);
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
    );
  }
}

/// Sticky footer: price breakdown + Continue/Checkout actions.
class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PriceSummary.standard(
                subtotal: cart.subtotal,
                tax: cart.tax,
                shipping: cart.shipping,
                total: cart.total,
              ),
              Gaps.h16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.goNamed(AppRoutes.nHome),
                      child: const Text(AppStrings.continueShopping),
                    ),
                  ),
                  Gaps.w12,
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.pushNamed(AppRoutes.nCheckout),
                      icon: const Icon(Icons.lock_outline_rounded,
                          size: AppSizes.iconSm),
                      label: const Text(AppStrings.checkout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
