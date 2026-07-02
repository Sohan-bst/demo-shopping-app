import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repository/product_repository.dart';

/// Drives the browsing experience: search text, active category filter and sort
/// order, exposing the resulting product list plus the curated home rails.
///
/// UI reads [results] (already filtered + sorted) and calls the mutators
/// ([setQuery], [setCategory], [setSort], [clearFilters]) which notify
/// listeners so the list rebuilds immediately.
class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repo);

  final ProductRepository _repo;

  String _query = '';
  String? _categoryId;
  ProductSort _sort = ProductSort.featured;

  String get query => _query;
  String? get categoryId => _categoryId;
  ProductSort get sort => _sort;

  /// True when any search text or category filter is active (sort excluded,
  /// since there's always some order). Used to show a "clear" affordance.
  bool get hasActiveFilters => _query.isNotEmpty || _categoryId != null;

  /// The catalog filtered by the current query/category and ordered by [sort].
  List<Product> get results => _repo.query(
        query: _query,
        categoryId: _categoryId,
        sort: _sort,
      );

  /// Curated home rails — independent of the active filters.
  List<Product> get featured => _repo.featured();
  List<Product> get latest => _repo.latest();

  /// Direct catalog lookups for detail/related views.
  Product? byId(String id) => _repo.byId(id);
  List<Product> relatedTo(Product product) => _repo.related(product);

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  /// Sets (or, when passed the already-active id, toggles off) the category
  /// filter. Passing null clears it.
  void setCategory(String? id) {
    final next = id == _categoryId ? null : id;
    if (next == _categoryId) return;
    _categoryId = next;
    notifyListeners();
  }

  void setSort(ProductSort value) {
    if (value == _sort) return;
    _sort = value;
    notifyListeners();
  }

  /// Resets search text and category (keeps the sort order).
  void clearFilters() {
    if (!hasActiveFilters) return;
    _query = '';
    _categoryId = null;
    notifyListeners();
  }
}
