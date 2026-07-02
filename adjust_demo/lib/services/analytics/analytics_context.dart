import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import 'analytics_service.dart';

/// Convenience helpers for firing screen-level analytics events from widgets.
///
/// Providers fire their own state-change events; screens use these for the
/// navigation-triggered events (view product, search).
extension AnalyticsContext on BuildContext {
  AnalyticsService get analytics => read<AnalyticsService>();

  void logViewProduct(Product product) {
    analytics.logEvent(AnalyticsEvents.viewProduct, params: {
      'product_id': product.id,
      'name': product.name,
      'category': product.categoryId,
      'price': product.price,
    });
  }

  void logSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    analytics.logEvent(AnalyticsEvents.search, params: {'query': q});
  }
}
