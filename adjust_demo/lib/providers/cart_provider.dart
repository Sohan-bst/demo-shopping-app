import 'package:flutter/foundation.dart';

import '../constants/app_config.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/analytics/analytics_service.dart';
import '../services/storage_service.dart';

/// Owns the shopping cart: the line items plus derived totals, persisted
/// locally so the cart survives app restarts.
///
/// All mutations ([add], [remove], [setQuantity], [increment], [decrement],
/// [clear]) update state, notify listeners and persist synchronously to
/// [StorageService]. This is the natural place to later fire Adjust events
/// (add-to-cart, remove, etc.).
class CartProvider extends ChangeNotifier {
  CartProvider(this._storage, this._analytics) {
    _load();
  }

  final StorageService _storage;
  final AnalyticsService _analytics;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  /// Total number of physical units across all lines (for the tab badge).
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  /// Number of distinct products in the cart.
  int get distinctCount => _items.length;

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  double get tax => subtotal * AppConfig.taxRate;

  /// Free over the threshold, otherwise a flat fee (zero for an empty cart).
  double get shipping {
    if (_items.isEmpty || subtotal >= AppConfig.freeShippingOver) return 0;
    return AppConfig.shippingFee;
  }

  double get total => subtotal + tax + shipping;

  /// Current quantity of [product] in the cart (0 if absent).
  int quantityOf(Product product) {
    final i = _indexOf(product.id);
    return i == -1 ? 0 : _items[i].quantity;
  }

  bool contains(Product product) => _indexOf(product.id) != -1;

  /// Adds [quantity] of [product], merging with any existing line and clamping
  /// to [AppConfig.maxQuantityPerItem].
  void add(Product product, {int quantity = 1}) {
    final i = _indexOf(product.id);
    if (i == -1) {
      _items.add(CartItem(product: product, quantity: _clamp(quantity)));
    } else {
      _items[i] =
          _items[i].copyWith(quantity: _clamp(_items[i].quantity + quantity));
    }
    _analytics.logEvent(AnalyticsEvents.addToCart, params: {
      'product_id': product.id,
      'name': product.name,
      'price': product.price,
      'quantity': quantity,
    });
    _commit();
  }

  void increment(Product product) => add(product);

  /// Decrements [product] by one, removing the line if it hits zero.
  void decrement(Product product) {
    final i = _indexOf(product.id);
    if (i == -1) return;
    final next = _items[i].quantity - 1;
    if (next <= 0) {
      _items.removeAt(i);
    } else {
      _items[i] = _items[i].copyWith(quantity: next);
    }
    _commit();
  }

  void setQuantity(Product product, int quantity) {
    final i = _indexOf(product.id);
    if (i == -1) return;
    if (quantity <= 0) {
      _items.removeAt(i);
    } else {
      _items[i] = _items[i].copyWith(quantity: _clamp(quantity));
    }
    _commit();
  }

  void remove(Product product) {
    final i = _indexOf(product.id);
    if (i == -1) return;
    _items.removeAt(i);
    _analytics.logEvent(AnalyticsEvents.removeFromCart, params: {
      'product_id': product.id,
      'name': product.name,
    });
    _commit();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _commit();
  }

  int _indexOf(String productId) =>
      _items.indexWhere((i) => i.product.id == productId);

  int _clamp(int q) => q.clamp(1, AppConfig.maxQuantityPerItem);

  void _commit() {
    notifyListeners();
    _persist();
  }

  void _persist() {
    _storage.setStringList(
      StorageService.keyCart,
      _items.map((i) => i.toJson()).toList(),
    );
  }

  void _load() {
    final raw = _storage.getStringList(StorageService.keyCart);
    for (final line in raw) {
      try {
        _items.add(CartItem.fromJson(line));
      } catch (_) {
        // Skip corrupt/legacy entries.
      }
    }
    if (_items.isNotEmpty) notifyListeners();
  }
}
