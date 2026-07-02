import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Adjust SDK implementation of [AnalyticsService] — **STUB / NOT YET WIRED**.
///
/// This is the drop-in replacement for [HttpAnalyticsService] to use once you
/// have an Adjust account. Because the whole app depends only on the
/// [AnalyticsService] interface, switching is a ONE-LINE change in `main.dart`:
///
///   // final AnalyticsService analytics = HttpAnalyticsService();
///   final AnalyticsService analytics = AdjustAnalyticsService();
///
/// No provider or screen code changes — the event names and call sites stay
/// exactly the same.
///
/// ── To activate ────────────────────────────────────────────────────────────
/// 1. Add the SDK to pubspec.yaml:      adjust_sdk: ^5.x.x
/// 2. Fill in [_appToken] below and the [_eventTokens] map with the event
///    tokens created in your Adjust dashboard.
/// 3. Uncomment the `import 'package:adjust_sdk/...';` lines and the SDK calls
///    marked `// ADJUST:` below.
/// ────────────────────────────────────────────────────────────────────────────
class AdjustAnalyticsService implements AnalyticsService {
  // TODO(adjust): paste your Adjust app token here.
  static const String _appToken = 'YOUR_ADJUST_APP_TOKEN';

  // TODO(adjust): map each canonical event name (AnalyticsEvents.*) to the
  // event token generated in the Adjust dashboard.
  static const Map<String, String> _eventTokens = {
    // AnalyticsEvents.login:      'abc123',
    // AnalyticsEvents.addToCart:  'def456',
    // AnalyticsEvents.purchase:   'ghi789',
  };

  @override
  Future<void> init() async {
    // ADJUST: initialize the SDK once at startup.
    //
    // final config = AdjustConfig(_appToken, AdjustEnvironment.sandbox);
    // Adjust.initSdk(config);
    debugPrint(
      '⚠️ AdjustAnalyticsService is a stub. Add the adjust_sdk package, set '
      'the app token ($_appToken) and event tokens, then uncomment the SDK '
      'calls. Using it now is a no-op.',
    );
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?> params = const {}}) async {
    final token = _eventTokens[name];
    if (token == null) return; // No token mapped for this event.

    // ADJUST: build and track the event.
    //
    // final event = AdjustEvent(token);
    // params.forEach((k, v) => event.addCallbackParameter(k, '$v'));
    // Adjust.trackEvent(event);
  }

  @override
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String orderId,
    Map<String, Object?> params = const {},
  }) async {
    // ADJUST: revenue event.
    //
    // final token = _eventTokens[AnalyticsEvents.purchase];
    // if (token == null) return;
    // final event = AdjustEvent(token)
    //   ..setRevenue(revenue, currency)
    //   ..addCallbackParameter('order_id', orderId);
    // params.forEach((k, v) => event.addCallbackParameter(k, '$v'));
    // Adjust.trackEvent(event);
  }
}
