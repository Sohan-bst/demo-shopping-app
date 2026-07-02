import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/analytics/analytics_service.dart';
import '../services/storage_service.dart';

/// Owns the user's order history, persisted locally.
///
/// [placeOrder] turns a cart snapshot + computed totals into an [Order] with a
/// generated number, prepends it to the history and persists. New orders start
/// as [OrderStatus.processing]; a couple of demo statuses are seeded so the
/// history shows Delivered/Cancelled variety on a fresh account.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._storage, this._analytics) {
    _load();
  }

  final StorageService _storage;
  final AnalyticsService _analytics;
  static const _uuid = Uuid();

  final List<Order> _orders = [];

  /// Orders, newest first.
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isEmpty => _orders.isEmpty;
  int get count => _orders.length;

  /// Creates and stores a new order from the given cart snapshot/totals.
  /// Returns the created [Order] (so the caller can show its number).
  Order placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
    required String paymentMethod,
    required DateTime placedAt,
  }) {
    final id = _uuid.v4();
    final order = Order(
      id: id,
      number: 'NOVA-${id.substring(0, 5).toUpperCase()}',
      items: items,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      placedAt: placedAt,
      status: OrderStatus.processing,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, order);
    _analytics.logPurchase(
      revenue: total,
      currency: 'USD',
      orderId: order.number,
      params: {
        'item_count': order.itemCount,
        'payment_method': paymentMethod,
      },
    );
    _commit();
    return order;
  }

  Order? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Updates an order's status (demo affordance in the Orders screen).
  void updateStatus(String id, OrderStatus status) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(status: status);
    _commit();
  }

  void clear() {
    if (_orders.isEmpty) return;
    _orders.clear();
    _commit();
  }

  void _commit() {
    notifyListeners();
    _storage.setStringList(
      StorageService.keyOrders,
      _orders.map((o) => o.toJson()).toList(),
    );
  }

  void _load() {
    final raw = _storage.getStringList(StorageService.keyOrders);
    for (final o in raw) {
      try {
        _orders.add(Order.fromJson(o));
      } catch (_) {
        // Skip corrupt entries.
      }
    }
    if (_orders.isNotEmpty) notifyListeners();
  }
}
