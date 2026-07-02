import 'package:flutter/material.dart';

/// A product category used to group and filter the catalog.
///
/// Backed by an [id] (stable, used in routing/persistence) plus display
/// metadata (label, icon, accent color) so category chips and headers render
/// consistently without the UI hard-coding any of it.
@immutable
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  /// Stable identifier, e.g. `electronics`. Matches [Product.categoryId].
  final String id;

  /// Human-readable name shown in chips and headers.
  final String label;

  /// Representative icon for the category.
  final IconData icon;

  /// Accent color used to tint the category's icon tile.
  final Color color;

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category($id)';
}
