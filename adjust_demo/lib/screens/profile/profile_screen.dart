import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/user_avatar.dart';

/// The account screen (Profile tab): identity header, quick stats, and links to
/// Edit Profile, Orders, Wishlist and Settings, plus Logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      // Should not happen (route is guarded), but fail gracefully.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final orderCount = context.select<OrdersProvider, int>((o) => o.count);
    final wishlistCount = context.select<WishlistProvider, int>((w) => w.count);
    final cartCount = context.select<CartProvider, int>((c) => c.totalQuantity);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        children: [
          // ---- Identity header -----------------------------------------
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                UserAvatar(user: user, size: 72),
                Gaps.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Gaps.h4,
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (user.memberSince != null) ...[
                        Gaps.h4,
                        Text(
                          '${AppStrings.memberSince} '
                          '${Formatters.date(user.memberSince!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Quick stats ---------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Row(
              children: [
                _Stat(label: AppStrings.orders, value: '$orderCount'),
                _Stat(label: AppStrings.wishlist, value: '$wishlistCount'),
                _Stat(label: AppStrings.cart, value: '$cartCount'),
              ],
            ),
          ),
          Gaps.h16,

          // ---- Menu ----------------------------------------------------
          SettingsTile(
            icon: Icons.edit_outlined,
            title: AppStrings.editProfile,
            onTap: () => context.pushNamed(AppRoutes.nEditProfile),
          ),
          SettingsTile(
            icon: Icons.receipt_long_outlined,
            title: AppStrings.orders,
            subtitle: orderCount == 0 ? 'No orders yet' : '$orderCount placed',
            onTap: () => context.pushNamed(AppRoutes.nOrders),
          ),
          SettingsTile(
            icon: Icons.favorite_border_rounded,
            title: AppStrings.wishlist,
            subtitle: '$wishlistCount saved',
            onTap: () => context.pushNamed(AppRoutes.nWishlist),
          ),
          SettingsTile(
            icon: Icons.settings_outlined,
            title: AppStrings.settings,
            onTap: () => context.goNamed(AppRoutes.nSettings),
          ),
          const Divider(height: AppSizes.xl),
          SettingsTile(
            icon: Icons.logout_rounded,
            title: AppStrings.logout,
            iconColor: AppColors.danger,
            titleColor: AppColors.danger,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      // The router's redirect sends unauthenticated users to login.
    }
  }
}

/// A single quick-stat card (Orders / Wishlist / Cart counts).
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
