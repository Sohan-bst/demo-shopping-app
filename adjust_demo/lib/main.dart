import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'repository/auth_repository.dart';
import 'repository/product_repository.dart';
import 'services/analytics/adjust_analytics_service.dart';
import 'services/analytics/analytics_service.dart';
import 'services/storage_service.dart';

/// Application entry point.
///
/// Initializes local storage + the analytics layer, wires up repositories and
/// providers, then runs the app. All app data is local/offline; user events
/// are forwarded to Adjust via [AdjustAnalyticsService] (configure tokens in
/// `constants/adjust_config.dart`).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted data before building any provider that reads from it.
  final storage = await StorageService.init();
  const productRepo = ProductRepository();

  // ── Analytics backend ──────────────────────────────────────────────────
  // The whole app depends only on the AnalyticsService interface, so the
  // backend is chosen here in one place.
  final AnalyticsService analytics = AdjustAnalyticsService();
  await analytics.init(); // boots the Adjust SDK + fires `app_opened`

  runApp(
    MultiProvider(
      providers: [
        // Expose the analytics backend so screens can fire screen-level events
        // (view_product, begin_checkout, search) directly.
        Provider<AnalyticsService>.value(value: analytics),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(storage), analytics),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(storage, analytics),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(storage, productRepo, analytics),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(storage, analytics),
        ),
      ],
      child: const NovaApp(),
    ),
  );
}
