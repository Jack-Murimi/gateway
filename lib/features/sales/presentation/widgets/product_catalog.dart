import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/breakpoints.dart';
import '../../../../design_system/theme/theme_extensions.dart';

import '../../domain/sales_models.dart';

/// Product catalog with search, quick-add buttons, and search results.
class ProductCatalog extends StatefulWidget {
  /// Creates the product catalog.
  const ProductCatalog({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.products,
    required this.quickAddProducts,
    required this.currency,
    required this.onAddToCart,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final List<Product> products;
  final List<Product> quickAddProducts;
  final NumberFormat currency;
  final void Function(Product product, {int quantity}) onAddToCart;

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  List<Product> _searchResults = [];
  var _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.products
            .where(
              (p) => p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          color: colorScheme.surface,
          child: TextField(
            controller: widget.searchController,
            focusNode: widget.searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products (F1)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.md,
              ),
            ),
          ),
        ),

        // Search results or quick-add grid
        Expanded(
          child: _searchQuery.isNotEmpty
              ? _SearchResultsList(
                  results: _searchResults,
                  currency: widget.currency,
                  onAddToCart: widget.onAddToCart,
                )
              : _QuickAddGrid(
                  products: widget.quickAddProducts,
                  allProducts: widget.products,
                  currency: widget.currency,
                  onAddToCart: widget.onAddToCart,
                ),
        ),
      ],
    );
  }
}

/// Search results list.
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.results,
    required this.currency,
    required this.onAddToCart,
  });

  final List<Product> results;
  final NumberFormat currency;
  final void Function(Product product, {int quantity}) onAddToCart;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: spacing.md),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final product = results[index];
        final isOutOfStock = product.stock <= 0;

        return ListTile(
          onTap: isOutOfStock ? null : () => onAddToCart(product),
          leading: CircleAvatar(
            backgroundColor: product.cylinderType != null
                ? colorScheme.tertiaryContainer
                : colorScheme.secondaryContainer,
            child: Icon(
              product.cylinderType != null
                  ? Icons.propane_tank_outlined
                  : Icons.inventory_2_outlined,
              size: 20,
              color: product.cylinderType != null
                  ? colorScheme.onTertiaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          title: Text(
            product.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isOutOfStock ? colorScheme.onSurfaceVariant : null,
            ),
          ),
          subtitle: Text(
            currency.format(product.price),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StockIndicator(stock: product.stock),
              SizedBox(width: spacing.sm),
              if (!isOutOfStock)
                IconButton.filledTonal(
                  onPressed: () => onAddToCart(product),
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add to cart',
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Stock level indicator chip.
class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;

    final Color bg;
    final Color fg;
    final String label;

    if (stock <= 0) {
      bg = colorScheme.errorContainer;
      fg = colorScheme.onErrorContainer;
      label = 'Out';
    } else if (stock < 10) {
      bg = colorScheme.tertiaryContainer;
      fg = colorScheme.onTertiaryContainer;
      label = '$stock left';
    } else {
      bg = colorScheme.surfaceContainerHighest;
      fg = colorScheme.onSurfaceVariant;
      label = '$stock';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(spacing.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

/// Grid of quick-add product tiles + all-products section.
class _QuickAddGrid extends StatelessWidget {
  const _QuickAddGrid({
    required this.products,
    required this.allProducts,
    required this.currency,
    required this.onAddToCart,
  });

  final List<Product> products;
  final List<Product> allProducts;
  final NumberFormat currency;
  final void Function(Product product, {int quantity}) onAddToCart;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompact = context.isCompact;

    return ListView(
      padding: EdgeInsets.all(spacing.lg),
      children: [
        // Quick add section
        Text(
          'Quick Add',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.md),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: products.map((product) {
            return _QuickAddChip(
              product: product,
              currency: currency,
              onTap: () => onAddToCart(product),
            );
          }).toList(),
        ),

        SizedBox(height: spacing.xl),

        // All products section
        Text(
          'All Products',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 2 : 3,
            childAspectRatio: isCompact ? 1.4 : 1.5,
            crossAxisSpacing: spacing.sm,
            mainAxisSpacing: spacing.sm,
          ),
          itemCount: allProducts.length,
          itemBuilder: (context, index) {
            final product = allProducts[index];
            return _ProductGridTile(
              product: product,
              currency: currency,
              onTap: product.stock > 0
                  ? () => onAddToCart(product)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

/// Compact quick-add chip.
class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({
    required this.product,
    required this.currency,
    required this.onTap,
  });

  final Product product;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      onPressed: product.stock > 0 ? onTap : null,
      avatar: Icon(
        Icons.add,
        size: 16,
        color: colorScheme.onPrimaryContainer,
      ),
      label: Text(
        '${product.name} · ${currency.format(product.price)}',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      backgroundColor: colorScheme.primaryContainer,
      side: BorderSide.none,
    );
  }
}

/// Tappable product grid tile.
class _ProductGridTile extends StatelessWidget {
  const _ProductGridTile({
    required this.product,
    required this.currency,
    required this.onTap,
  });

  final Product product;
  final NumberFormat currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final isOutOfStock = product.stock <= 0;

    return Material(
      color: isOutOfStock
          ? colorScheme.surfaceContainerLow
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(spacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spacing.md),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    product.cylinderType != null
                        ? Icons.propane_tank_outlined
                        : Icons.inventory_2_outlined,
                    size: 18,
                    color: isOutOfStock
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                        : colorScheme.primary,
                  ),
                  const Spacer(),
                  _StockIndicator(stock: product.stock),
                ],
              ),
              const Spacer(),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOutOfStock
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                currency.format(product.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
