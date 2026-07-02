import 'dart:convert';

import 'cart_item.dart';

/// Lifecycle status of a placed order.
enum OrderStatus {
  processing('Processing'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  static OrderStatus fromName(String name) =>
      OrderStatus.values.firstWhere((s) => s.name == name,
          orElse: () => OrderStatus.processing);
}

/// A completed purchase.
///
/// Captures a snapshot of the cart lines and the computed totals at checkout
/// time, plus a human-friendly [number] and a [status] for the order history.
/// Immutable and serializable for local persistence.
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.placedAt,
    required this.status,
    required this.paymentMethod,
  });

  final String id;

  /// Display order number, e.g. `NOVA-8F3K2`.
  final String number;

  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final DateTime placedAt;
  final OrderStatus status;
  final String paymentMethod;

  /// Total number of physical units in the order.
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        number: number,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        placedAt: placedAt,
        status: status ?? this.status,
        paymentMethod: paymentMethod,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'shipping': shipping,
        'total': total,
        'placedAt': placedAt.toIso8601String(),
        'status': status.name,
        'paymentMethod': paymentMethod,
      };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'] as String,
        number: map['number'] as String,
        items: (map['items'] as List)
            .map((e) => CartItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        subtotal: (map['subtotal'] as num).toDouble(),
        tax: (map['tax'] as num).toDouble(),
        shipping: (map['shipping'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
        placedAt: DateTime.parse(map['placedAt'] as String),
        status: OrderStatus.fromName(map['status'] as String),
        paymentMethod: map['paymentMethod'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
