import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_sizes.dart';
import '../../data/category_data.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../navigation/app_routes.dart';
import '../../providers/product_provider.dart';
import '../../services/analytics/analytics_context.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_field.dart';

/// The catalog browse surface: search, category filter chips, a sort menu and
/// a responsive results grid.
///
/// State (query / category / sort) lives in [ProductProvider], so filters set
/// from Home (search or a category tap) are already applied when this screen
/// opens. Set [autofocusSearch] to open with the keyboard up.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.autofocusSearch = false});

  final bool autofocusSearch;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Seed the field with any query already in the provider (e.g. restored).
    _searchController =
        TextEditingController(text: context.read<ProductProvider>().query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final results = products.results;
    final activeCategory = products.categoryId == null
        ? null
        : CategoryData.byId(products.categoryId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(activeCategory?.label ?? 'All products'),
        actions: [
          _SortMenu(
            current: products.sort,
            onSelected: products.setSort,
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Search --------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.sm,
            ),
            child: SearchField(
              controller: _searchController,
              autofocus: widget.autofocusSearch,
              onChanged: products.setQuery,
              onSubmitted: context.logSearch,
              onClear: () => products.setQuery(''),
            ),
          ),

          // ---- Category filter chips -----------------------------------
          _CategoryFilterBar(
            selectedId: products.categoryId,
            onSelected: products.setCategory,
          ),

          // ---- Result count + clear ------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.xs,
            ),
            child: Row(
              children: [
                Text(
                  '${results.length} '
                  '${results.length == 1 ? 'result' : 'results'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                if (products.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      products.clearFilters();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),

          // ---- Results grid --------------------------------------------
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No products found',
                    message: 'Try a different search or clear your filters.',
                    actionLabel: products.hasActiveFilters ? 'Clear filters' : null,
                    onAction: products.hasActiveFilters
                        ? () {
                            products.clearFilters();
                            _searchController.clear();
                          }
                        : null,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      AppSizes.sm,
                      AppSizes.lg,
                      AppSizes.xl,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: AppSizes.productGridMaxExtent,
                      mainAxisSpacing: AppSizes.md,
                      crossAxisSpacing: AppSizes.md,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final product = results[i];
                      return ProductCard(
                        product: product,
                        onTap: () => _openProduct(context, product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    // view_product is fired by ProductDetailsScreen on open (single source).
    context.pushNamed(
      AppRoutes.nProduct,
      pathParameters: {'id': product.id},
    );
  }
}

/// Horizontally-scrolling row of category filter chips (with an "All" chip).
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        children: [
          _Chip(
            label: 'All',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final Category c in CategoryData.all) ...[
            Gaps.w8,
            _Chip(
              label: c.label,
              icon: c.icon,
              selected: selectedId == c.id,
              // The provider toggles a re-tap off, so tapping the active chip
              // clears it; pass the id to select.
              onTap: () => onSelected(c.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilterChip(
        label: Text(label),
        avatar: icon == null ? null : Icon(icon, size: AppSizes.iconSm),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// The sort action in the app bar: an icon that opens a menu of [ProductSort]
/// options with the current one checked.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onSelected});

  final ProductSort current;
  final ValueChanged<ProductSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductSort>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort',
      initialValue: current,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final sort in ProductSort.values)
          PopupMenuItem<ProductSort>(
            value: sort,
            child: Row(
              children: [
                Icon(
                  sort == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: AppSizes.iconSm,
                  color: sort == current
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Gaps.w12,
                Text(sort.label),
              ],
            ),
          ),
      ],
    );
  }
}
