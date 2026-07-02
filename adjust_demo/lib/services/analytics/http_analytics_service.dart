import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../constants/analytics_config.dart';
import 'analytics_service.dart';

/// Demo [AnalyticsService] that POSTs each event as JSON to a configurable
/// endpoint ([AnalyticsConfig.eventEndpoint]) so events can be inspected and
/// replayed in Postman / webhook.site while there is no real SDK yet.
///
/// Every event is also printed to the debug console (see [AnalyticsConfig]),
/// so you can verify firing even without a live endpoint. Sends are
/// fire-and-forget and never throw: a network failure logs a warning but never
/// disrupts the user action that triggered it.
///
/// Swap this for `AdjustAnalyticsService` in `main.dart` once you have Adjust.
class HttpAnalyticsService implements AnalyticsService {
  HttpAnalyticsService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<void> init() => logEvent(AnalyticsEvents.appOpened);

  @override
  Future<void> logEvent(String name, {Map<String, Object?> params = const {}}) {
    final payload = <String, Object?>{
      'app_token': AnalyticsConfig.appToken,
      'event': name,
      // ISO timestamp is added by the receiver's clock too, but include a
      // client-side marker for correlation.
      'params': params,
    };
    return _send(name, payload);
  }

  @override
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String orderId,
    Map<String, Object?> params = const {},
  }) {
    return logEvent(AnalyticsEvents.purchase, params: {
      'revenue': revenue,
      'currency': currency,
      'order_id': orderId,
      ...params,
    });
  }

  Future<void> _send(String name, Map<String, Object?> payload) async {
    final body = jsonEncode(payload);

    if (AnalyticsConfig.logToConsole) {
      // A compact, greppable line: "📊 analytics » add_to_cart {…}"
      debugPrint('📊 analytics » $name $body');
    }

    if (!AnalyticsConfig.sendOverHttp || !AnalyticsConfig.hasRealEndpoint) {
      // No real endpoint configured yet — console log above is the record.
      return;
    }

    try {
      final res = await _client
          .post(
            Uri.parse(AnalyticsConfig.eventEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode >= 400) {
        debugPrint('⚠️ analytics HTTP ${res.statusCode} for "$name"');
      }
    } catch (e) {
      // Never let analytics break a user action.
      debugPrint('⚠️ analytics send failed for "$name": $e');
    }
  }
}
