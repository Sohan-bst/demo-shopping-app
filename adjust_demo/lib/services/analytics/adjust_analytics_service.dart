import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:flutter/foundation.dart';

import '../../constants/adjust_config.dart';
import 'analytics_service.dart';

/// [AnalyticsService] backed by the Adjust SDK (v5).
///
/// Forwards the app's canonical events to Adjust: [init] boots the SDK,
/// [logEvent] tracks a mapped event with its params as callback parameters,
/// and [logPurchase] additionally attaches revenue.
///
/// Configuration (app token, environment, per-event tokens) lives in
/// [AdjustSettings]. Events whose token is unmapped or still a placeholder are
/// skipped, so partial dashboard setup never breaks the app. Every call is
/// also mirrored to the debug console (`📊 analytics » …`) for easy local
/// verification, and never throws — analytics must not disrupt a user action.
class AdjustAnalyticsService implements AnalyticsService {
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (AdjustSettings.isAppTokenPlaceholder) {
      debugPrint(
        '⚠️ Adjust app token is still the placeholder. Set AdjustSettings.'
        'appToken (and event tokens) — the SDK will init but events without a '
        'real token are skipped.',
      );
    }

    try {
      final config = AdjustConfig(
        AdjustSettings.appToken,
        AdjustSettings.environment,
      )..logLevel = AdjustSettings.logLevel;

      Adjust.initSdk(config);
      _initialized = true;
      debugPrint('📊 analytics » Adjust SDK initialized '
          '(${AdjustSettings.environment.name})');
    } catch (e) {
      debugPrint('⚠️ Adjust init failed: $e');
    }

    // The SDK tracks the session automatically; mirror an app_opened marker.
    await logEvent(AnalyticsEvents.appOpened);
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    if (AdjustSettings.logLevel == AdjustLogLevel.verbose) {
      debugPrint('📊 analytics » $name $params');
    }

    final token = AdjustSettings.tokenFor(name);
    if (token == null || !_initialized) return; // unmapped/placeholder → skip

    try {
      final event = AdjustEvent(token);
      _attach(event, params);
      Adjust.trackEvent(event);
    } catch (e) {
      debugPrint('⚠️ Adjust trackEvent("$name") failed: $e');
    }
  }

  @override
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String orderId,
    Map<String, Object?> params = const {},
  }) async {
    if (AdjustSettings.logLevel == AdjustLogLevel.verbose) {
      debugPrint('📊 analytics » purchase '
          '{revenue: $revenue $currency, order: $orderId, $params}');
    }

    final token = AdjustSettings.tokenFor(AnalyticsEvents.purchase);
    if (token == null || !_initialized) return;

    try {
      final event = AdjustEvent(token)
        ..setRevenue(revenue, currency)
        ..addCallbackParameter('order_id', orderId);
      _attach(event, params);
      Adjust.trackEvent(event);
    } catch (e) {
      debugPrint('⚠️ Adjust purchase event failed: $e');
    }
  }

  @override
  Future<void> logAdRevenue({
    required String source,
    required double revenue,
    required String currency,
    String? network,
    String? unit,
    String? placement,
  }) async {
    if (AdjustSettings.logLevel == AdjustLogLevel.verbose) {
      debugPrint('📊 analytics » ad_revenue '
          '{source: $source, revenue: $revenue $currency, network: $network}');
    }

    if (!_initialized) return;

    try {
      final adRevenue = AdjustAdRevenue(source)
        ..setRevenue(revenue, currency);
      if (network != null) adRevenue.adRevenueNetwork = network;
      if (unit != null) adRevenue.adRevenueUnit = unit;
      if (placement != null) adRevenue.adRevenuePlacement = placement;
      Adjust.trackAdRevenue(adRevenue);
    } catch (e) {
      debugPrint('⚠️ Adjust ad revenue failed: $e');
    }
  }

  /// Adjust callback parameters are string key/values; stringify each param.
  void _attach(AdjustEvent event, Map<String, Object?> params) {
    params.forEach((key, value) {
      if (value != null) event.addCallbackParameter(key, '$value');
    });
  }
}
