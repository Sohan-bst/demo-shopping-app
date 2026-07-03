import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_sizes.dart';
import '../services/analytics/analytics_service.dart';
import '../utils/snackbar.dart';

/// A promotional card that simulates a **rewarded video ad**.
///
/// Tapping "Watch" shows a short fake "ad playing" dialog, then fires an Adjust
/// **ad-revenue** event via [AnalyticsService.logAdRevenue] — so the demo can
/// exercise Adjust's ad-monetization tracking without integrating a real ad
/// network. The revenue/network values are representative sample data.
class WatchAdCard extends StatefulWidget {
  const WatchAdCard({super.key});

  @override
  State<WatchAdCard> createState() => _WatchAdCardState();
}

class _WatchAdCardState extends State<WatchAdCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              scheme.tertiary.withValues(alpha: 0.14),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(Icons.play_circle_fill_rounded,
                  color: scheme.primary, size: AppSizes.iconLg),
            ),
            Gaps.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn 50 coins',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Gaps.h4,
                  Text(
                    'Watch a short video',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            FilledButton(
              // Bounded min size so the themed full-width minimum doesn't
              // demand infinite width inside this Row (which would collapse
              // the whole scroll view's layout).
              style: FilledButton.styleFrom(
                minimumSize: const Size(88, 44),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              ),
              onPressed: _playing ? null : _watchAd,
              child: _playing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Watch'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _playing = true);

    // Simulate the rewarded video playing.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              SizedBox(width: AppSizes.md),
              Text('Playing ad…'),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    // Fire the ad-revenue event with representative sample values.
    context.read<AnalyticsService>().logAdRevenue(
          source: 'admob_sdk',
          revenue: 0.02,
          currency: 'USD',
          network: 'AdMob',
          unit: 'rewarded_home',
          placement: 'home_reward',
        );

    setState(() => _playing = false);
    AppSnackbar.success(context, 'Reward earned! +50 coins');
  }
}
