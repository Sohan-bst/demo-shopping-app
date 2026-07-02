import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../utils/formatters.dart';

/// A single label/value row in a price summary.
class PriceRow {
  const PriceRow(this.label, this.value, {this.emphasize = false, this.muted = false});

  final String label;

  /// Pre-formatted value string (e.g. `$12.99` or `Free`).
  final String value;

  /// Renders as a bold "total" row.
  final bool emphasize;

  /// Renders in a subdued color (e.g. a discount line).
  final bool muted;
}

/// A reusable order/price breakdown (subtotal, tax, shipping, total…).
///
/// Shared by the Cart and Checkout screens so the money math is displayed
/// identically. Callers pass ready-made [rows]; use [PriceSummary.standard] for
/// the common subtotal/tax/shipping/total set.
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.rows});

  final List<PriceRow> rows;

  /// Builds the standard breakdown. Pass [discount] > 0 to include a discount
  /// line (shown as a negative amount).
  factory PriceSummary.standard({
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
    double discount = 0,
  }) {
    return PriceSummary(
      rows: [
        PriceRow(AppStrings.subtotal, Formatters.price(subtotal)),
        if (discount > 0)
          PriceRow(
            AppStrings.discount,
            '-${Formatters.price(discount)}',
            muted: true,
          ),
        PriceRow(AppStrings.tax, Formatters.price(tax)),
        PriceRow(
          AppStrings.shipping,
          shipping == 0 ? AppStrings.free : Formatters.price(shipping),
        ),
        PriceRow(AppStrings.total, Formatters.price(total), emphasize: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        for (final row in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row.label,
                  style: row.emphasize
                      ? theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                ),
                Text(
                  row.value,
                  style: row.emphasize
                      ? theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        )
                      : theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: row.muted ? scheme.tertiary : null,
                        ),
                ),
              ],
            ),
          ),
          if (row.emphasize) const SizedBox.shrink() else const Divider(height: 1),
        ],
      ],
    );
  }
}
