import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// A pill-shaped search input with a leading search icon and a clear button
/// that appears once there's text.
///
/// Purely presentational — the owner supplies the [controller] and reacts to
/// [onChanged]/[onSubmitted]. Set [readOnly] with an [onTap] to use it as a
/// tappable "search bar" that navigates to a dedicated search screen.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Search products',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          readOnly: readOnly,
          autofocus: autofocus,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                      onChanged?.call('');
                    },
                  )
                : null,
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(vertical: AppSizes.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
        );
      },
    );
  }
}
