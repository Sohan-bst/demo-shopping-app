import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';

/// Deterministic visual mapping for products used to draw placeholder images.
///
/// The app ships no binary product photos; instead each product is rendered as
/// a colored tile with a representative glyph. Both the color (from
/// [AppColors.productSwatches]) and the icon are derived from the product's
/// stable [Product.imageSeed], so a given product always looks the same.
class ProductVisuals {
  const ProductVisuals._();

  /// Maps known image seeds to a representative icon. Unmapped seeds fall back
  /// to a generic box glyph.
  static const Map<String, IconData> _icons = {
    'gaming-mouse': Icons.mouse_rounded,
    'mech-keyboard': Icons.keyboard_rounded,
    'bt-speaker': Icons.speaker_rounded,
    'usbc-hub': Icons.usb_rounded,
    'earbuds': Icons.earbuds_rounded,
    'laptop-stand': Icons.laptop_mac_rounded,
    'ssd': Icons.storage_rounded,
    'webcam': Icons.videocam_rounded,
    'microphone': Icons.mic_rounded,
    'controller': Icons.sports_esports_rounded,
    'monitor': Icons.desktop_windows_rounded,
    'office-chair': Icons.chair_rounded,
    'desk-lamp': Icons.light_rounded,
    'book-cleancode': Icons.menu_book_rounded,
    'notebook': Icons.book_rounded,
    'pencil': Icons.edit_rounded,
    'power-bank': Icons.battery_charging_full_rounded,
    'smart-watch': Icons.watch_rounded,
    'hdmi': Icons.settings_input_hdmi_rounded,
    'backpack': Icons.backpack_rounded,
    'wireless-charger': Icons.wifi_tethering_rounded,
  };

  static IconData iconFor(Product product) =>
      _icons[product.imageSeed] ?? Icons.inventory_2_rounded;

  /// Picks a stable swatch for [product] by hashing its seed.
  static Color colorFor(Product product) {
    final swatches = AppColors.productSwatches;
    final index = product.imageSeed.hashCode.abs() % swatches.length;
    return swatches[index];
  }
}
