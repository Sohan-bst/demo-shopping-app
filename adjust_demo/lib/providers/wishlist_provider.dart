import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repository/product_repository.dart';
import '../services/analytics/analytics_service.dart';
import '../services/storage_service.dart';

/// Owns the wishlist: a set of favourited product ids, persisted locally.
///
/// Stores ids (not full products) and resolves them against the catalog on
/// read, so the wishlist stays small and always reflects current product data.
class WishlistProvider extends ChangeNotifier {
  WishlistProvider(this._storage, this._repo, this._analytics) {
    _load();
  }

  final StorageService _storage;
  final ProductRepository _repo;
  final AnalyticsService _analytics;

  /// Insertion-ordered set of wishlisted product ids.
  final Set<String> _ids = <String>{};

  bool get isEmpty => _ids.isEmpty;
  int get count => _ids.length;

  bool contains(Product product) => _ids.contains(product.id);
  bool containsId(String id) => _ids.contains(id);

  /// The wishlisted products, resolved from the catalog (skips unknown ids).
  List<Product> get products {
    final list = <Product>[];
    for (final id in _ids) {
      final p = _repo.byId(id);
      if (p != null) list.add(p);
    }
    return list;
  }

  /// Adds/removes [product]; returns the new membership (true = now saved).
  bool toggle(Product product) {
    final nowSaved = !_ids.contains(product.id);
    if (nowSaved) {
      _ids.add(product.id);
    } else {
      _ids.remove(product.id);
    }
    _logWishlist(product, added: nowSaved);
    _commit();
    return nowSaved;
  }

  void add(Product product) {
    if (_ids.add(product.id)) {
      _logWishlist(product, added: true);
      _commit();
    }
  }

  void remove(Product product) {
    if (_ids.remove(product.id)) {
      _logWishlist(product, added: false);
      _commit();
    }
  }

  void _logWishlist(Product product, {required bool added}) {
    _analytics.logEvent(
      added
          ? AnalyticsEvents.addToWishlist
          : AnalyticsEvents.removeFromWishlist,
      params: {'product_id': product.id, 'name': product.name},
    );
  }

  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    _commit();
  }

  void _commit() {
    notifyListeners();
    _storage.setStringList(StorageService.keyWishlist, _ids.toList());
  }

  void _load() {
    _ids.addAll(_storage.getStringList(StorageService.keyWishlist));
    if (_ids.isNotEmpty) notifyListeners();
  }
}
