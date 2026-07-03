import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../data/category_data.dart';
import '../../models/product.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_header.dart';
import '../../widgets/watch_ad_card.dart';

/// The store landing screen (Home tab).
///
/// Shows a personalized greeting, a tappable search bar that opens the product
/// list, a categories rail, a "Featured" horizontal rail and a "Latest" grid.
/// Tapping search or a category deep-links into the product list with the
/// matching filter pre-applied.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Fixed width of a card on the horizontal "Featured" rail.
  static const double _railCardWidth = 168;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = context.select<AuthProvider, String>(
      (a) => (a.user?.name ?? 'there').split(' ').first,
    );
    final products = context.watch<ProductProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {}, // Local data — pull-to-refresh is cosmetic.
          child: CustomScrollView(
            slivers: [
              // ---- Greeting + search --------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.lg,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName 👋',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Gaps.h4,
                      Text(
                        'What are you shopping for today?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Gaps.h16,
                      SearchField(
                        controller: TextEditingController(),
                        readOnly: true,
                        onTap: () => _openList(context, focusSearch: true),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Rewarded ad (fires Adjust ad-revenue) ------------------
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.sm,
                    AppSizes.lg,
                    0,
                  ),
                  child: WatchAdCard(),
                ),
              ),

              // ---- Categories ---------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    0,
                  ),
                  child: SectionHeader(
                    title: 'Categories',
                    actionLabel: 'See all',
                    onAction: () => _openList(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 124,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.xs,
                    ),
                    itemCount: CategoryData.all.length,
                    separatorBuilder: (_, _) => Gaps.w8,
                    itemBuilder: (context, i) {
                      final category = CategoryData.all[i];
                      return CategoryTile(
                        category: category,
                        onTap: () => _openCategory(context, category.id),
                      );
                    },
                  ),
                ),
              ),

              // ---- Featured rail ------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    0,
                  ),
                  child: SectionHeader(
                    title: 'Featured',
                    actionLabel: 'See all',
                    onAction: () => _openList(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 268,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm,
                    ),
                    itemCount: products.featured.length,
                    separatorBuilder: (_, _) => Gaps.w12,
                    itemBuilder: (context, i) {
                      final product = products.featured[i];
                      return SizedBox(
                        width: _railCardWidth,
                        child: ProductCard(
                          product: product,
                          onTap: () => _openProduct(context, product),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ---- Latest grid --------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: const SectionHeader(title: 'Latest arrivals'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  0,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: AppSizes.productGridMaxExtent,
                    mainAxisSpacing: AppSizes.md,
                    crossAxisSpacing: AppSizes.md,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final product = products.latest[i];
                      return ProductCard(
                        product: product,
                        onTap: () => _openProduct(context, product),
                      );
                    },
                    childCount: products.latest.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    // The view_product event is fired by ProductDetailsScreen when it opens,
    // so it's recorded exactly once regardless of where navigation started.
    context.pushNamed(
      AppRoutes.nProduct,
      pathParameters: {'id': product.id},
    );
  }

  /// Opens the product list, clearing any prior filters. When [focusSearch] is
  /// set the list autofocuses its search field.
  void _openList(BuildContext context, {bool focusSearch = false}) {
    context.read<ProductProvider>().clearFilters();
    context.pushNamed(
      AppRoutes.nProducts,
      queryParameters: focusSearch ? {'search': '1'} : const {},
    );
  }

  void _openCategory(BuildContext context, String categoryId) {
    final products = context.read<ProductProvider>();
    products.clearFilters();
    products.setCategory(categoryId);
    context.pushNamed(AppRoutes.nProducts);
  }
}
