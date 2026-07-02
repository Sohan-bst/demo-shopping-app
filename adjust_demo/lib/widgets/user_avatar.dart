import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_colors.dart';

/// A circular avatar showing the user's initials on a deterministic brand-tinted
/// gradient. Used on the profile screen and profile menu entry.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 64});

  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Pick a stable swatch from the avatar seed (falls back to the name).
    final seed = (user.avatarSeed ?? user.name);
    final swatch = AppColors
        .productSwatches[seed.hashCode.abs() % AppColors.productSwatches.length];

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [swatch, swatch.withValues(alpha: 0.7)],
        ),
      ),
      child: Text(
        user.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
