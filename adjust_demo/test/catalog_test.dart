import 'package:flutter_test/flutter_test.dart';

import 'package:adjust_demo/data/product_data.dart';
import 'package:adjust_demo/models/product.dart';
import 'package:adjust_demo/providers/product_provider.dart';
import 'package:adjust_demo/repository/product_repository.dart';
import 'package:adjust_demo/utils/formatters.dart';

void main() {
  const repo = ProductRepository();

  group('ProductRepository', () {
    test('byId returns the matching product or null', () {
      expect(repo.byId('p01')?.id, 'p01');
      expect(repo.byId('does-not-exist'), isNull);
    });

    test('query filters by category', () {
      final gaming = repo.query(categoryId: 'gaming');
      expect(gaming, isNotEmpty);
      expect(gaming.every((p) => p.categoryId == 'gaming'), isTrue);
    });

    test('query matches name and description, case-insensitively', () {
      final results = repo.query(query: 'KEYBOARD');
      expect(results.any((p) => p.name.contains('Keyboard')), isTrue);
    });

    test('query returns empty for an impossible search', () {
      expect(repo.query(query: 'zzzzz-nothing'), isEmpty);
    });

    test('sort priceLowHigh orders ascending by price', () {
      final sorted = repo.query(sort: ProductSort.priceLowHigh);
      for (var i = 1; i < sorted.length; i++) {
        expect(sorted[i - 1].price <= sorted[i].price, isTrue);
      }
    });

    test('sort ratingHighLow orders descending by rating', () {
      final sorted = repo.query(sort: ProductSort.ratingHighLow);
      for (var i = 1; i < sorted.length; i++) {
        expect(sorted[i - 1].rating >= sorted[i].rating, isTrue);
      }
    });

    test('related excludes the product itself and fills to the limit', () {
      final product = ProductData.all.first;
      final related = repo.related(product);
      expect(related.contains(product), isFalse);
      expect(related.length, lessThanOrEqualTo(6));
    });

    test('featured is limited and rating-ordered', () {
      final featured = repo.featured(limit: 4);
      expect(featured.length, 4);
      for (var i = 1; i < featured.length; i++) {
        expect(featured[i - 1].rating >= featured[i].rating, isTrue);
      }
    });
  });

  group('ProductProvider', () {
    test('setCategory toggles off when re-selecting the same id', () {
      final provider = ProductProvider(repo);
      provider.setCategory('gaming');
      expect(provider.categoryId, 'gaming');
      provider.setCategory('gaming'); // re-tap clears
      expect(provider.categoryId, isNull);
    });

    test('hasActiveFilters reflects query and category state', () {
      final provider = ProductProvider(repo);
      expect(provider.hasActiveFilters, isFalse);
      provider.setQuery('mouse');
      expect(provider.hasActiveFilters, isTrue);
      provider.clearFilters();
      expect(provider.hasActiveFilters, isFalse);
    });

    test('results reflect the active category filter', () {
      final provider = ProductProvider(repo)..setCategory('audio');
      expect(provider.results.every((p) => p.categoryId == 'audio'), isTrue);
    });
  });

  group('Product model', () {
    test('stock helpers classify availability', () {
      const out = Product(
        id: 'x',
        name: 'X',
        categoryId: 'c',
        price: 1,
        rating: 1,
        ratingCount: 1,
        stock: 0,
        description: 'd',
        imageSeed: 's',
      );
      expect(out.inStock, isFalse);
      expect(out.copyWith(stock: 3).isLowStock, isTrue);
      expect(out.copyWith(stock: 50).isLowStock, isFalse);
    });

    test('round-trips through JSON', () {
      final product = ProductData.all.first;
      expect(Product.fromJson(product.toJson()), product);
    });
  });

  group('Formatters', () {
    test('price formats with thousands separators and two decimals', () {
      expect(Formatters.price(1234.5), r'$1,234.50');
      expect(Formatters.price(9.99), r'$9.99');
    });

    test('compactCount abbreviates thousands', () {
      expect(Formatters.compactCount(950), '950');
      expect(Formatters.compactCount(1284), '1.3k');
    });
  });
}
