/// Centralized route paths and names for [GoRouter].
///
/// Using constants (rather than string literals scattered across the app)
/// prevents typos and makes navigation targets easy to find and refactor.
class AppRoutes {
  const AppRoutes._();

  // Paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Named sub/detail routes (added in later phases)
  static const String products = '/products'; // catalog browse (search/filter)
  static const String product = 'product/:id'; // pushed under /products
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String editProfile = '/edit-profile';

  // Route names (for context.goNamed)
  static const String nSplash = 'splash';
  static const String nLogin = 'login';
  static const String nRegister = 'register';
  static const String nHome = 'home';
  static const String nCart = 'cart';
  static const String nProfile = 'profile';
  static const String nSettings = 'settings';
  static const String nProducts = 'products';
  static const String nProduct = 'product';
  static const String nWishlist = 'wishlist';
  static const String nCheckout = 'checkout';
  static const String nOrderSuccess = 'orderSuccess';
  static const String nOrders = 'orders';
  static const String nEditProfile = 'editProfile';
}
