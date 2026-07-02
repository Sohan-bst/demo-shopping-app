import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// A compact 5-star rating display supporting half stars, optionally followed
/// by the numeric rating and (compact) rating count.
///
/// Read-only — this is a display widget, not an input.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.ratingCount,
    this.size = AppSizes.iconSm,
    this.showValue = true,
  });

  final double rating;
  final int? ratingCount;
  final double size;

  /// Whether to append the numeric rating (e.g. `4.7`) after the stars.
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            _iconFor(i),
            size: size,
            color: AppColors.rating,
          ),
        if (showValue) ...[
          Gaps.w4,
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (ratingCount != null) ...[
          Gaps.w4,
          Text(
            '(${Formatters.compactCount(ratingCount!)})',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Full / half / empty star for the [position]-th star (1-based).
  IconData _iconFor(int position) {
    if (rating >= position) return Icons.star_rounded;
    if (rating >= position - 0.5) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }
}
