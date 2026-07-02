import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/order.dart';
import '../../navigation/app_routes.dart';
import '../../providers/orders_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/product_image.dart';

/// The order history.
///
/// Lists placed orders newest-first, each as an expandable card showing its
/// number, date, status and line items. Tapping the status lets you cycle it
/// through Processing → Delivered → Cancelled (a demo affordance for testing
/// state changes).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.orders)),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.emptyOrdersTitle,
              message: AppStrings.emptyOrdersMessage,
              actionLabel: AppStrings.continueShopping,
              onAction: () => context.goNamed(AppRoutes.nHome),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.lg),
              itemCount: orders.length,
              separatorBuilder: (_, _) => Gaps.h12,
              itemBuilder: (context, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Theme(
        // Remove the default ExpansionTile divider lines for a cleaner card.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            0,
            AppSizes.lg,
            AppSizes.md,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  order.number,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => _cycleStatus(context),
                child: OrderStatusBadge(status: order.status),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSizes.xs),
            child: Text(
              '${Formatters.date(order.placedAt)} · '
              '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · '
              '${Formatters.price(order.total)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          children: [
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      child: SizedBox(
                        height: 44,
                        width: 44,
                        child: ProductImage(
                            product: item.product, iconScale: 0.5),
                      ),
                    ),
                    Gaps.w12,
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Gaps.w8,
                    Text('×${item.quantity}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    Gaps.w12,
                    Text(
                      Formatters.price(item.lineTotal),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                Icon(Icons.payment_rounded,
                    size: AppSizes.iconSm,
                    color: theme.colorScheme.onSurfaceVariant),
                Gaps.w8,
                Text('Paid via ${order.paymentMethod}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Cycles Processing → Delivered → Cancelled → Processing (demo affordance).
  void _cycleStatus(BuildContext context) {
    const order = OrderStatus.values;
    final next = order[(this.order.status.index + 1) % order.length];
    context.read<OrdersProvider>().updateStatus(this.order.id, next);
  }
}
