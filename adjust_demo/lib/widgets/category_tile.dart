import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../models/category.dart';

/// A tappable category tile: a rounded, tinted icon badge above the category
/// label. Used in the home "Categories" rail.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.width = 84,
  });

  final Category category;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Column(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: AppSizes.iconLg,
                ),
              ),
              Gaps.h8,
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
