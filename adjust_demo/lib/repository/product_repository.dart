import '../data/product_data.dart';
import '../models/product.dart';

/// Read-only access to the product catalog.
///
/// The catalog is a fixed, in-memory list of fake data. This repository
/// isolates the query logic (search, category filter, sort, related items,
/// featured/latest slices) from the UI and provider layers so those concerns
/// stay simple and the data source can be swapped later without touching them.
class ProductRepository {
  const ProductRepository();

  /// The full, unfiltered catalog.
  List<Product> all() => ProductData.all;

  /// Looks up a single product by [id], or null if not found.
  Product? byId(String id) {
    for (final p in ProductData.all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Runs a catalog query: optional [query] text match and [categoryId] filter,
  /// then orders the result by [sort].
  ///
  /// Matching is case-insensitive and spans the product name and description.
  List<Product> query({
    String? query,
    String? categoryId,
    ProductSort sort = ProductSort.featured,
  }) {
    final q = query?.trim().toLowerCase() ?? '';

    final results = ProductData.all.where((p) {
      final matchesCategory = categoryId == null || p.categoryId == categoryId;
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();

    _sort(results, sort);
    return results;
  }

  /// A curated slice for the home "Featured" rail: the highest-rated products.
  List<Product> featured({int limit = 6}) {
    final list = List<Product>.from(ProductData.all)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(limit).toList();
  }

  /// A slice for the home "Latest" rail.
  ///
  /// With no timestamps in the demo data, "latest" is simply the tail of the
  /// catalog (the most recently added ids), reversed so the newest lead.
  List<Product> latest({int limit = 8}) {
    return ProductData.all.reversed.take(limit).toList();
  }

  /// Products related to [product]: same category, excluding itself, ordered by
  /// rating. Falls back to top-rated items from other categories if the product
  /// is the only one in its category.
  List<Product> related(Product product, {int limit = 6}) {
    final sameCategory = ProductData.all
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (sameCategory.length >= limit) return sameCategory.take(limit).toList();

    // Top up with other high-rated products so the rail is never sparse.
    final fill = ProductData.all
        .where((p) =>
            p.id != product.id && p.categoryId != product.categoryId)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return [...sameCategory, ...fill].take(limit).toList();
  }

  /// Sorts [list] in place according to [sort].
  ///
  /// `featured` keeps the natural catalog order (a hand-curated arrangement).
  void _sort(List<Product> list, ProductSort sort) {
    switch (sort) {
      case ProductSort.featured:
        break;
      case ProductSort.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.ratingHighLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSort.nameAZ:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
  }
}
