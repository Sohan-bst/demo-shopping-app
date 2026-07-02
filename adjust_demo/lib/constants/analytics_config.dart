/// Configuration for the (swappable) analytics layer.
///
/// For now the app fires demo events as HTTP POSTs to [eventEndpoint] so they
/// can be inspected/replayed in Postman or a request bin. When the real Adjust
/// SDK is added later, this file's HTTP settings become irrelevant and the app
/// switches to [AdjustAnalyticsService] (see `services/analytics/`).
class AnalyticsConfig {
  const AnalyticsConfig._();

  /// Where demo events are POSTed.
  ///
  /// ⚠️ REPLACE THIS with your own test endpoint:
  ///   • https://webhook.site  → copy your unique URL (easiest; live view), or
  ///   • a Postman Mock Server URL, or
  ///   • your own server/webhook.
  /// The default below is a placeholder and will simply fail to connect until
  /// you set a real URL — event details are still printed to the console.
  static const String eventEndpoint =
      'https://webhook.site/2e9109a0-11d7-4eb9-b781-fef80d8aba49';

  /// Master switch for network sending. When false (or the endpoint is still
  /// the placeholder), events are only logged to the console — handy offline.
  static const bool sendOverHttp = true;

  /// Always print each event to the debug console / logcat, even when HTTP is
  /// enabled, so you can verify events without a live endpoint.
  static const bool logToConsole = true;

  /// Demo "app token" included in every payload so the shape resembles a real
  /// analytics call. Replace with your Adjust app token when you integrate.
  static const String appToken = 'DEMO-APP-TOKEN';

  /// True when a real endpoint has been configured.
  static bool get hasRealEndpoint =>
      !eventEndpoint.contains('REPLACE-WITH-YOUR-UUID');
}
