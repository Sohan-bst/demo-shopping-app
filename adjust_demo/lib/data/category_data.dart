import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_colors.dart';

/// The fixed set of demo categories.
///
/// Ordered as they should appear on the home screen. Each category's [id] is
/// referenced by products in `product_data.dart`.
class CategoryData {
  const CategoryData._();

  static const List<Category> all = <Category>[
    Category(
      id: 'electronics',
      label: 'Electronics',
      icon: Icons.memory_rounded,
      color: AppColors.brandSeed,
    ),
    Category(
      id: 'gaming',
      label: 'Gaming',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF9B6CF5),
    ),
    Category(
      id: 'accessories',
      label: 'Accessories',
      icon: Icons.cable_rounded,
      color: Color(0xFF00C2A8),
    ),
    Category(
      id: 'books',
      label: 'Books',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF08A5D),
    ),
    Category(
      id: 'audio',
      label: 'Audio',
      icon: Icons.headphones_rounded,
      color: Color(0xFFEE6C8B),
    ),
    Category(
      id: 'office',
      label: 'Office',
      icon: Icons.chair_rounded,
      color: Color(0xFF5B8DEF),
    ),
  ];

  /// Looks up a category by [id], or null if unknown.
  static Category? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Convenience label lookup with a safe fallback.
  static String labelOf(String id) => byId(id)?.label ?? 'All';
}
