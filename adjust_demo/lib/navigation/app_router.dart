import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/products/product_details_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import 'app_routes.dart';

/// Root navigator key. Hosts full-screen routes (auth, splash, catalog browse,
/// product details, checkout flow, orders, wishlist, edit profile) that cover
/// the bottom-navigation shell.
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Builds the app's [GoRouter].
///
/// Listens to [AuthProvider] and guards routes with [redirect]: unauthenticated
/// users are pushed to Login and signed-in users are kept out of the auth
/// screens; splash routes itself onward after its animation.
///
/// A [StatefulShellRoute.indexedStack] powers the bottom navigation
/// (Home/Cart/Profile/Settings), preserving each tab's state. Detail and flow
/// screens are pushed on the root navigator so they present full-screen.
GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final onAuthScreen = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.splash;
      final loggedIn = status == AuthStatus.authenticated;

      if (!loggedIn && !onAuthScreen) return AppRoutes.login;

      if (loggedIn &&
          (location == AppRoutes.login || location == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.nRegister,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ---- Catalog browse + product details (full-screen) ----------------
      GoRoute(
        path: AppRoutes.products,
        name: AppRoutes.nProducts,
        builder: (context, state) => ProductListScreen(
          autofocusSearch: state.uri.queryParameters['search'] == '1',
        ),
        routes: [
          GoRoute(
            path: AppRoutes.product, // product/:id
            name: AppRoutes.nProduct,
            builder: (context, state) => ProductDetailsScreen(
              productId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // ---- Purchase flow -------------------------------------------------
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.nCheckout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        name: AppRoutes.nOrderSuccess,
        builder: (context, state) =>
            OrderSuccessScreen(order: state.extra as Order),
      ),

      // ---- Secondary full-screen destinations ----------------------------
      GoRoute(
        path: AppRoutes.orders,
        name: AppRoutes.nOrders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        name: AppRoutes.nWishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.nEditProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // ---- Bottom-navigation shell ---------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.nHome,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: AppRoutes.nCart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.nProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.nSettings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
