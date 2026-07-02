import 'package:flutter/material.dart';

import '../constants/app_durations.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

/// Helpers for showing consistent, themed [SnackBar]s from anywhere with a
/// [BuildContext]. Clears any in-flight snackbar first so rapid actions don't
/// stack up.
class AppSnackbar {
  const AppSnackbar._();

  static void info(BuildContext context, String message) =>
      _show(context, message, icon: Icons.info_outline);

  static void success(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.check_circle_outline,
        background: AppColors.success,
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.error_outline,
        background: AppColors.danger,
      );

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    Color? background,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final onColor = background == null ? null : Colors.white;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: AppDurations.snackbar,
          backgroundColor: background,
          content: Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: onColor),
              Gaps.w12,
              Expanded(
                child: Text(
                  message,
                  style: onColor == null ? null : TextStyle(color: onColor),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
