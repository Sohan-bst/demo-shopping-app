import 'dart:convert';

import 'product.dart';

/// A single line in the shopping cart: a [product] and its [quantity].
///
/// Immutable; embeds the full product snapshot so the cart can render and
/// total itself without re-querying the catalog (and so persisted carts still
/// work if the catalog changes). Serializable for local persistence.
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  /// Line total = unit price × quantity.
  double get lineTotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toMap() => {
        'product': product.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        product: Product.fromMap(map['product'] as Map<String, dynamic>),
        quantity: map['quantity'] as int,
      );

  String toJson() => jsonEncode(toMap());

  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
