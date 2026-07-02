import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adjust_demo/constants/app_config.dart';
import 'package:adjust_demo/data/product_data.dart';
import 'package:adjust_demo/providers/cart_provider.dart';
import 'package:adjust_demo/providers/orders_provider.dart';
import 'package:adjust_demo/providers/wishlist_provider.dart';
import 'package:adjust_demo/repository/product_repository.dart';
import 'package:adjust_demo/services/analytics/analytics_service.dart';
import 'package:adjust_demo/services/storage_service.dart';

import 'support/fake_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late FakeAnalytics analytics;

  setUp(() async {
    // Fresh, empty prefs for each test.
    SharedPreferences.setMockInitialValues({});
    storage = await StorageService.init();
    await storage.clearAll();
    analytics = FakeAnalytics();
  });

  group('CartProvider', () {
    test('add merges quantities and computes totals', () {
      final cart = CartProvider(storage, analytics);
      final cheap = ProductData.all.firstWhere((p) => p.price < 20);

      cart.add(cheap, quantity: 2);
      cart.add(cheap); // merges → qty 3
      expect(cart.distinctCount, 1);
      expect(cart.totalQuantity, 3);
      expect(cart.subtotal, closeTo(cheap.price * 3, 0.001));
      expect(cart.tax, closeTo(cart.subtotal * AppConfig.taxRate, 0.001));
    });

    test('quantity clamps to the per-item max', () {
      final cart = CartProvider(storage, analytics);
      final p = ProductData.all.first;
      cart.add(p, quantity: 999);
      expect(cart.quantityOf(p), AppConfig.maxQuantityPerItem);
    });

    test('decrement removes the line at zero', () {
      final cart = CartProvider(storage, analytics);
      final p = ProductData.all.first;
      cart.add(p);
      cart.decrement(p);
      expect(cart.contains(p), isFalse);
      expect(cart.isEmpty, isTrue);
    });

    test('free shipping over the threshold, flat fee below', () {
      final cart = CartProvider(storage, analytics);
      final cheap = ProductData.all.firstWhere((p) => p.price < 20);
      cart.add(cheap); // below threshold
      expect(cart.shipping, AppConfig.shippingFee);

      final pricey =
          ProductData.all.firstWhere((p) => p.price >= AppConfig.freeShippingOver);
      cart.clear();
      cart.add(pricey);
      expect(cart.shipping, 0);
    });

    test('persists across provider instances', () {
      final p = ProductData.all.first;
      CartProvider(storage, analytics).add(p, quantity: 2);
      // A new provider reading the same storage should see the saved line.
      final reloaded = CartProvider(storage, analytics);
      expect(reloaded.quantityOf(p), 2);
    });
  });

  group('WishlistProvider', () {
    test('toggle adds then removes and persists', () {
      const repo = ProductRepository();
      final p = ProductData.all.first;
      final w = WishlistProvider(storage, repo, analytics);

      expect(w.toggle(p), isTrue); // now saved
      expect(w.contains(p), isTrue);
      expect(w.products.map((e) => e.id), contains(p.id));

      expect(w.toggle(p), isFalse); // removed
      expect(w.contains(p), isFalse);

      // Persistence check.
      final reloaded = WishlistProvider(storage, repo, analytics);
      expect(reloaded.isEmpty, isTrue);
    });
  });

  group('OrdersProvider', () {
    test('placeOrder records an order with a number, newest first', () {
      final cart = CartProvider(storage, analytics);
      final p = ProductData.all.first;
      cart.add(p, quantity: 2);

      final orders = OrdersProvider(storage, analytics);
      final order = orders.placeOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        tax: cart.tax,
        shipping: cart.shipping,
        total: cart.total,
        paymentMethod: 'Credit / Debit Card',
        placedAt: DateTime(2026, 3, 12),
      );

      expect(order.number, startsWith('NOVA-'));
      expect(order.itemCount, 2);
      expect(orders.count, 1);
      expect(orders.orders.first.id, order.id);

      // Persisted and reloadable.
      final reloaded = OrdersProvider(storage, analytics);
      expect(reloaded.count, 1);
      expect(reloaded.orders.first.number, order.number);
    });
  });

  group('Analytics wiring', () {
    test('cart, wishlist and purchase fire the expected events', () {
      final p = ProductData.all.first;

      final cart = CartProvider(storage, analytics)..add(p);
      expect(analytics.logged(AnalyticsEvents.addToCart), isTrue);
      cart.remove(p);
      expect(analytics.logged(AnalyticsEvents.removeFromCart), isTrue);

      WishlistProvider(storage, const ProductRepository(), analytics).toggle(p);
      expect(analytics.logged(AnalyticsEvents.addToWishlist), isTrue);

      OrdersProvider(storage, analytics).placeOrder(
        items: [],
        subtotal: 10,
        tax: 1,
        shipping: 0,
        total: 11,
        paymentMethod: 'PayPal',
        placedAt: DateTime(2026, 1, 1),
      );
      final purchase =
          analytics.events.firstWhere((e) => e.name == AnalyticsEvents.purchase);
      expect(purchase.params['revenue'], 11);
      expect(purchase.params['currency'], 'USD');
    });
  });
}
