/// Centralized, user-facing copy for the app.
///
/// Keeping strings in one place makes the UI consistent, simplifies future
/// localization, and gives test/automation code stable text to assert against.
class AppStrings {
  const AppStrings._();

  // ---- Branding ----------------------------------------------------------
  static const String appName = 'Nova Store';
  static const String appTagline = 'Tech that moves with you';

  // ---- Auth --------------------------------------------------------------
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String createAccount = 'Create account';
  static const String forgotPassword = 'Forgot password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String welcomeBack = 'Welcome back';
  static const String signInToContinue = 'Sign in to continue shopping';
  static const String joinNova = 'Join Nova Store';
  static const String createAccountSubtitle =
      'Create an account to start shopping';

  // ---- Field labels ------------------------------------------------------
  static const String name = 'Full name';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';

  // ---- Validation --------------------------------------------------------
  static const String errRequired = 'This field is required';
  static const String errEmailInvalid = 'Enter a valid email address';
  static const String errPasswordShort =
      'Password must be at least 6 characters';
  static const String errNameShort = 'Name must be at least 2 characters';
  static const String errPasswordMismatch = 'Passwords do not match';

  // ---- Common actions ----------------------------------------------------
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String close = 'Close';

  // ---- Snackbars / dialogs (Phase 1) ------------------------------------
  static const String forgotPasswordInfo =
      'Password reset is not available in this demo.';
  static const String loginFailed = 'Unable to sign in. Please try again.';

  // ---- Catalog / product (Phase 2) --------------------------------------
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
  static const String addToWishlist = 'Add to Wishlist';
  static const String share = 'Share';
  static const String outOfStock = 'Out of stock';
  static const String inStock = 'In stock';
  static const String relatedProducts = 'You may also like';

  static const String shareInfo = 'Sharing is not available in this demo.';

  // ---- Cart / wishlist ---------------------------------------------------
  static const String cart = 'Cart';
  static const String wishlist = 'Wishlist';
  static const String continueShopping = 'Continue Shopping';
  static const String checkout = 'Checkout';
  static const String moveToCart = 'Move to Cart';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax';
  static const String shipping = 'Shipping';
  static const String total = 'Total';
  static const String free = 'Free';
  static const String addedToCart = 'Added to cart';
  static const String removedFromCart = 'Removed from cart';
  static const String addedToWishlist = 'Added to wishlist';
  static const String removedFromWishlist = 'Removed from wishlist';
  static const String emptyCartTitle = 'Your cart is empty';
  static const String emptyCartMessage =
      'Browse the store and add items to get started.';
  static const String emptyWishlistTitle = 'No favourites yet';
  static const String emptyWishlistMessage =
      'Tap the heart on any product to save it here.';

  // ---- Checkout ----------------------------------------------------------
  static const String shippingAddress = 'Shipping Address';
  static const String paymentMethod = 'Payment Method';
  static const String orderSummary = 'Order Summary';
  static const String promoCode = 'Promo Code';
  static const String applyPromo = 'Apply';
  static const String placeOrder = 'Place Order';
  static const String promoApplied = 'Promo code applied';
  static const String promoInvalid = 'Invalid promo code';
  static const String discount = 'Discount';

  // ---- Order success / orders -------------------------------------------
  static const String orderPlaced = 'Order placed!';
  static const String orderPlacedSubtitle =
      'Thanks for shopping with Nova Store.';
  static const String viewOrders = 'View Orders';
  static const String orders = 'Orders';
  static const String emptyOrdersTitle = 'No orders yet';
  static const String emptyOrdersMessage =
      'Your placed orders will appear here.';

  // ---- Profile / settings ------------------------------------------------
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String memberSince = 'Member since';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark mode';
  static const String about = 'About';
  static const String version = 'Version';
  static const String resetDemoData = 'Reset Demo Data';
  static const String clearCart = 'Clear Cart';
  static const String resetDemoConfirm =
      'This clears your cart, wishlist and order history. Continue?';
  static const String dataReset = 'Demo data reset';
  static const String cartCleared = 'Cart cleared';
  static const String logoutConfirm = 'Are you sure you want to log out?';
}
