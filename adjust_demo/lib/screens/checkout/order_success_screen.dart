import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/order.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

/// Confirmation shown after a successful checkout.
///
/// Receives the placed [Order] via GoRouter `extra`. Offers a jump to the
/// order history or back to the store. There is no back button — this is a
/// terminal screen for the purchase flow (reached via pushReplacement).
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success illustration (drawn, not an asset).
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 72,
                  ),
                ),
              ),
              Gaps.h32,
              Text(
                AppStrings.orderPlaced,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Gaps.h8,
              Text(
                AppStrings.orderPlacedSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Gaps.h32,

              // Order number + total card.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    children: [
                      _row(context, 'Order number', order.number),
                      const Divider(height: AppSizes.xl),
                      _row(context, 'Items', '${order.itemCount}'),
                      const Divider(height: AppSizes.xl),
                      _row(
                        context,
                        AppStrings.total,
                        Formatters.price(order.total),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              FilledButton.icon(
                onPressed: () => context.goNamed(AppRoutes.nOrders),
                icon: const Icon(Icons.receipt_long_rounded,
                    size: AppSizes.iconSm),
                label: const Text(AppStrings.viewOrders),
              ),
              Gaps.h12,
              OutlinedButton(
                onPressed: () => context.goNamed(AppRoutes.nHome),
                child: const Text(AppStrings.continueShopping),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool emphasize = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: emphasize
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
