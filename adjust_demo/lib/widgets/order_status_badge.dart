import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';

/// A colored pill showing an [OrderStatus] (Delivered / Processing / Cancelled).
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      OrderStatus.delivered => (AppColors.statusDelivered, Icons.check_circle_rounded),
      OrderStatus.processing => (AppColors.statusProcessing, Icons.local_shipping_rounded),
      OrderStatus.cancelled => (AppColors.statusCancelled, Icons.cancel_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSizes.xs),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
