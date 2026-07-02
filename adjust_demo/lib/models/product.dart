import 'dart:convert';

/// A catalog product.
///
/// This is fake, locally-generated demo data — there is no backend. The model
/// is immutable and serializable so it can be embedded in persisted cart lines,
/// wishlist entries and orders in later phases.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.stock,
    required this.description,
    required this.imageSeed,
  });

  final String id;
  final String name;

  /// Matches [Category.id]; links a product to its category.
  final String categoryId;

  /// Price in USD.
  final double price;

  /// Average rating on a 0–5 scale.
  final double rating;

  /// Number of ratings, shown alongside [rating] for realism.
  final int ratingCount;

  /// Units in stock. `0` means out of stock.
  final int stock;

  final String description;

  /// Seed used to procedurally draw a deterministic placeholder image
  /// (color + glyph) so no binary image assets are required.
  final String imageSeed;

  bool get inStock => stock > 0;

  /// True when stock is low enough to nudge urgency in the UI.
  bool get isLowStock => stock > 0 && stock <= 5;

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? price,
    double? rating,
    int? ratingCount,
    int? stock,
    String? description,
    String? imageSeed,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageSeed: imageSeed ?? this.imageSeed,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'categoryId': categoryId,
        'price': price,
        'rating': rating,
        'ratingCount': ratingCount,
        'stock': stock,
        'description': description,
        'imageSeed': imageSeed,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        categoryId: map['categoryId'] as String,
        price: (map['price'] as num).toDouble(),
        rating: (map['rating'] as num).toDouble(),
        ratingCount: map['ratingCount'] as int,
        stock: map['stock'] as int,
        description: map['description'] as String,
        imageSeed: map['imageSeed'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product($id, $name)';
}

/// Ways the product list can be ordered. Drives the sort menu.
enum ProductSort {
  featured('Featured'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low'),
  ratingHighLow('Top Rated'),
  nameAZ('Name: A to Z');

  const ProductSort(this.label);

  /// Human-readable label for the sort menu.
  final String label;
}
