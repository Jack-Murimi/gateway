import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../inventory/domain/product.dart';

/// Product search bar with inline autocomplete.
/// Keyboard nav: Up/Down to select, Enter to add, Escape to clear.
class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.products,
    required this.currency,
    required this.onAddToCart,
    this.showShortcutHint = true,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final List<Product> products;
  final NumberFormat currency;
  final void Function(Product product, {int quantity}) onAddToCart;
  final bool showShortcutHint;

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  List<Product> _searchResults = [];
  var _searchQuery = '';
  var _selectedIndex = 0;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _selectedIndex = 0;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        // Multi-token search: split by spaces, all tokens must match
        final tokens = query.toLowerCase().split(' ').where((t) => t.isNotEmpty).toList();
        _searchResults = widget.products
            .where((p) {
              final name = p.name.toLowerCase();
              return tokens.every((token) => name.contains(token));
            })
            .toList();
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_searchResults.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _searchResults.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + _searchResults.length) % _searchResults.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _addSelectedProduct();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.searchController.clear();
      _onSearchChanged('');
    }
  }

  void _addSelectedProduct() {
    if (_searchResults.isEmpty) return;
    final product = _searchResults[_selectedIndex];
    widget.onAddToCart(product);
    widget.searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: _handleKeyEvent,
            child: TextField(
              controller: widget.searchController,
              focusNode: widget.searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.showShortcutHint
                    ? 'Search products (F1)'
                    : 'Search products',
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
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: spacing.xs),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(spacing.sm),
              child: _searchResults.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(spacing.lg),
                      child: Row(
                        children: [
                          Icon(Icons.search_off, color: colorScheme.outline),
                          SizedBox(width: spacing.sm),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          final isSelected = index == _selectedIndex;
                          // ponytail: stock check removed - needs getStock function

                          return ListTile(
                            dense: true,
                            selected: isSelected,
                            selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
                            onTap: () {
                              widget.onAddToCart(product);
                              widget.searchController.clear();
                              _onSearchChanged('');
                            },
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: product.kind == ProductKind.refill || product.kind == ProductKind.emptyCylinder
                                  ? colorScheme.tertiaryContainer
                                  : colorScheme.secondaryContainer,
                              child: Icon(
                                product.kind == ProductKind.refill || product.kind == ProductKind.emptyCylinder
                                    ? Icons.propane_tank_outlined
                                    : Icons.inventory_2_outlined,
                                size: AppSizes.iconSm,
                                color: product.kind == ProductKind.refill || product.kind == ProductKind.emptyCylinder
                                    ? colorScheme.onTertiaryContainer
                                    : colorScheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              widget.currency.format(product.price),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            trailing: null, // ponytail: stock display needs getStock function
                          );
                        },
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
