import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// A full-width [FilledButton] that shows an inline spinner while [isLoading],
/// disabling itself so an action can't be triggered twice.
///
/// Optionally renders a leading [icon]. Used for all primary CTAs (login,
/// register, add-to-cart, place-order…) to keep them visually consistent.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: AppSizes.iconMd,
            width: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm),
                Gaps.w8,
              ],
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}
