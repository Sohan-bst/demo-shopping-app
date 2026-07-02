/// Animation and timing constants used throughout the app.
///
/// Centralizing durations keeps motion feeling consistent and makes it easy to
/// globally speed up animations (e.g. for UI test runs).
class AppDurations {
  const AppDurations._();

  /// Minimum time the splash screen stays visible before routing away.
  static const Duration splash = Duration(milliseconds: 2200);

  /// Simulated network latency for fake async operations (login, checkout…).
  static const Duration fakeNetwork = Duration(milliseconds: 900);

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// How long transient snackbars remain on screen.
  static const Duration snackbar = Duration(seconds: 2);
}
