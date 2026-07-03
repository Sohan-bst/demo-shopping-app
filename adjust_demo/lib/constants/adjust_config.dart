import 'package:adjust_sdk/adjust_config.dart';

import '../services/analytics/analytics_service.dart';

/// Adjust SDK configuration for the app.
///
/// ⚠️ All values below are PLACEHOLDERS. Paste your real Adjust credentials
/// from the dashboard (https://dash.adjust.com):
///   • [appToken]     — Settings → App info
///   • [eventTokens]  — one token per event you created (Events tab)
///
/// The app token and event tokens are *public identifiers* (they ship inside
/// every build), so keeping them in source is standard and safe — there is no
/// secret key in the client SDK.
class AdjustSettings {
  const AdjustSettings._();

  /// Your Adjust app token. Replace the placeholder.
  static const String appToken = 'bwvz3zev5o1s';

  /// Environment. `production` sends data to the live Datascape dashboards /
  /// Insights (with processing lag). Use `sandbox` for the Testing Console.
  static const AdjustEnvironment environment = AdjustEnvironment.production;

  /// Verbose while integrating so events are visible in logcat. For an actual
  /// public release, set this to [AdjustLogLevel.suppress].
  static const AdjustLogLevel logLevel = AdjustLogLevel.verbose;

  /// Maps each app event name ([AnalyticsEvents]) to its Adjust event token.
  ///
  /// Replace every 'CHANGE_ME_*' with the real token from the dashboard. Any
  /// event left as a placeholder (or removed from this map) is simply skipped
  /// by [AdjustAnalyticsService] — it will not be sent.
  static const Map<String, String> eventTokens = {
    AnalyticsEvents.appOpened: 'y1m3k4',
    AnalyticsEvents.login: 'w1uvub',
    AnalyticsEvents.register: 'rz61gw',
    AnalyticsEvents.logout: 'wxo1us',
    AnalyticsEvents.search: 'si7mhj',
    AnalyticsEvents.viewProduct: '2kscdv',
    AnalyticsEvents.addToCart: 'dvpgwr',
    AnalyticsEvents.removeFromCart: '4er2sc',
    AnalyticsEvents.addToWishlist: 'kjd3r2',
    AnalyticsEvents.removeFromWishlist: 'gtlxkx',
    AnalyticsEvents.beginCheckout: 'xe60dk',
    AnalyticsEvents.purchase: '88ahe2',
  };

  /// The sentinel prefix marking an unconfigured token.
  static const String _placeholderPrefix = 'CHANGE_ME';

  /// True when [appToken] still holds the placeholder value.
  static bool get isAppTokenPlaceholder => appToken == 'YOUR_ADJUST_APP_TOKEN';

  /// Returns the Adjust event token for [eventName], or null if it is unmapped
  /// or still a placeholder (so callers skip sending it).
  static String? tokenFor(String eventName) {
    final token = eventTokens[eventName];
    if (token == null || token.startsWith(_placeholderPrefix)) return null;
    return token;
  }
}
