import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

/// Scaffold that hosts the four primary tabs (Home, Cart, Profile, Settings)
/// behind a Material 3 [NavigationBar].
///
/// Built for a [StatefulShellRoute.indexedStack], which preserves each tab's
/// navigation stack and scroll position when switching between them. The Cart
/// tab shows a live badge with the number of items in the cart.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  /// The shell driving the indexed stack of tab branches.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>((c) => c.totalQuantity);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // `initialLocation: true` when re-tapping the active tab pops it back to
    // that branch's root — the expected "tap home to go home" behavior.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
