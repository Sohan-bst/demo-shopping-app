import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/settings_tile.dart';

/// App settings: theme, data management (clear cart / reset demo data) and
/// About. All actions operate on local state/persistence.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Kept in sync with `pubspec.yaml`'s `version:` field.
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        children: [
          _sectionLabel(context, AppStrings.appearance),
          SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: AppStrings.darkMode,
            trailing: Switch(
              value: themeProvider.isDark,
              onChanged: (v) => context.read<ThemeProvider>().toggleDark(v),
            ),
          ),

          _sectionLabel(context, 'Data'),
          SettingsTile(
            icon: Icons.remove_shopping_cart_outlined,
            title: AppStrings.clearCart,
            iconColor: AppColors.warning,
            onTap: () {
              context.read<CartProvider>().clear();
              AppSnackbar.info(context, AppStrings.cartCleared);
            },
          ),
          SettingsTile(
            icon: Icons.restart_alt_rounded,
            title: AppStrings.resetDemoData,
            iconColor: AppColors.danger,
            onTap: () => _confirmReset(context),
          ),

          _sectionLabel(context, AppStrings.about),
          SettingsTile(
            icon: Icons.info_outline_rounded,
            title: AppStrings.about,
            subtitle: 'A Flutter demo store for feature & SDK testing.',
            onTap: () => _showAbout(context),
          ),
          SettingsTile(
            icon: Icons.tag_rounded,
            title: AppStrings.version,
            subtitle: appVersion,
          ),
          Gaps.h24,
          Center(
            child: Text(
              '${AppStrings.appName} · v$appVersion',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Gaps.h24,
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.xs,
        ),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
      );

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.resetDemoData),
        content: const Text(AppStrings.resetDemoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // Clear each provider (each persists its own cleared state).
      context.read<CartProvider>().clear();
      context.read<WishlistProvider>().clear();
      context.read<OrdersProvider>().clear();
      AppSnackbar.success(context, AppStrings.dataReset);
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: 'v$appVersion',
      applicationIcon: const Padding(
        padding: EdgeInsets.all(AppSizes.sm),
        child: BrandLogo(size: 48, showName: false),
      ),
      children: const [
        Padding(
          padding: EdgeInsets.only(top: AppSizes.sm),
          child: Text(
            'Nova Store is an offline Flutter demo application built to '
            'exercise common e-commerce user flows — auth, browsing, cart, '
            'checkout and orders — for feature testing and SDK integration.',
          ),
        ),
      ],
    );
  }
}
