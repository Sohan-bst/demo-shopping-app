/// Canonical event names fired by the app.
///
/// Centralized so the (swappable) analytics backends and any dashboard
/// configuration agree on names. When you wire up Adjust, map each of these to
/// an Adjust **event token** in [AdjustAnalyticsService].
class AnalyticsEvents {
  const AnalyticsEvents._();

  static const String appOpened = 'app_opened';
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String search = 'search';
  static const String viewProduct = 'view_product';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String addToWishlist = 'add_to_wishlist';
  static const String removeFromWishlist = 'remove_from_wishlist';
  static const String beginCheckout = 'begin_checkout';
  static const String purchase = 'purchase';
}

/// A single analytics/attribution backend.
///
/// The whole app depends only on this interface — providers call
/// [logEvent]/[logPurchase] and never reference a concrete SDK. Swapping
/// backends (HTTP now → Adjust later) is a one-line change in `main.dart`; no
/// provider or screen code changes.
abstract interface class AnalyticsService {
  /// Called once at startup for one-time setup (open the session, init SDK…).
  Future<void> init();

  /// Records a named event with optional flat string/number/bool [params].
  ///
  /// Fire-and-forget by contract: implementations must not throw — a failed
  /// send should never break a user action.
  Future<void> logEvent(String name, {Map<String, Object?> params});

  /// Convenience for revenue events (checkout). [revenue] is the order total,
  /// [currency] an ISO code (e.g. `USD`). Extra fields go in [params].
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String orderId,
    Map<String, Object?> params,
  });
}
