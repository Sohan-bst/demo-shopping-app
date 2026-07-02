/// Store-wide numeric configuration for the demo (tax, shipping, promo codes).
///
/// Centralized so checkout math is consistent and easy to tweak.
class AppConfig {
  const AppConfig._();

  /// Sales tax applied to the cart subtotal (8%).
  static const double taxRate = 0.08;

  /// Flat shipping fee applied when the subtotal is below [freeShippingOver].
  static const double shippingFee = 5.99;

  /// Orders at or above this subtotal ship free.
  static const double freeShippingOver = 75.0;

  /// Max units of a single product allowed in the cart.
  static const int maxQuantityPerItem = 10;

  /// Promo codes recognized at checkout → fractional discount on the subtotal.
  static const Map<String, double> promoCodes = {
    'NOVA10': 0.10,
    'WELCOME': 0.15,
    'DEMO20': 0.20,
  };
}
