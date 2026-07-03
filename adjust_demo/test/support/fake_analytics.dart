import 'package:adjust_demo/services/analytics/analytics_service.dart';

/// Test double for [AnalyticsService] that records fired events instead of
/// sending them, so tests can assert on analytics without any network.
class FakeAnalytics implements AnalyticsService {
  final List<({String name, Map<String, Object?> params})> events = [];

  bool logged(String name) => events.any((e) => e.name == name);

  @override
  Future<void> init() async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object?> params = const {}}) async {
    events.add((name: name, params: params));
  }

  @override
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String orderId,
    Map<String, Object?> params = const {},
  }) async {
    events.add((
      name: AnalyticsEvents.purchase,
      params: {
        'revenue': revenue,
        'currency': currency,
        'order_id': orderId,
        ...params,
      },
    ));
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
    events.add((
      name: AnalyticsEvents.adRevenue,
      params: {
        'source': source,
        'revenue': revenue,
        'currency': currency,
        'network': network,
        'unit': unit,
        'placement': placement,
      },
    ));
  }
}
