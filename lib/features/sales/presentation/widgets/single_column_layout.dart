import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../domain/sales_models.dart';
import 'inline_cart_tile.dart';
import 'inline_cart_footer.dart';

/// Single-column layout — used on ALL screen sizes.
/// Cart items live inline (no right panel). Footer pinned to bottom.
class SingleColumnLayout extends StatelessWidget {
  const SingleColumnLayout({
    super.key,
    required this.header,
    required this.searchBar,
    required this.lineItems,
    required this.currency,
    required this.grandTotal,
    required this.totalItems,
    required this.scrollController,
    required this.onRemoveFromCart,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.onSave,
    required this.showFloatingBar,
  });

  final Widget header;
  final Widget searchBar;
  final List<SaleLineItem> lineItems;
  final NumberFormat currency;
  final int grandTotal;
  final int totalItems;
  final ScrollController scrollController;
  final ValueChanged<int> onRemoveFromCart;
  final void Function(int index, int quantity) onUpdateQuantity;
  final VoidCallback onClearCart;
  final VoidCallback? onSave;
  final bool showFloatingBar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // On large screens the footer is constrained + right-aligned.
    final isLarge = !showFloatingBar;
    final footerMaxWidth = isLarge ? 420.0 : double.infinity;

    return Column(
      children: [
        // Scrollable content: header + search + cart items
        Expanded(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header + search
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    header,
                    const Divider(height: 1),
                    searchBar,
                  ],
                ),
              ),

              // Inline cart items
              if (lineItems.isNotEmpty) ...[
                // Cart section header
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.lg,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      border: Border(
                        bottom: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: AppSizes.iconMd,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'Cart',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Badge(
                          label: Text('$totalItems'),
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: onClearCart,
                          icon: Icon(Icons.delete_sweep_outlined, size: AppSizes.iconMd),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cart line items
                SliverList.builder(
                  itemCount: lineItems.length,
                  itemBuilder: (context, index) {
                    final item = lineItems[index];
                    return InlineCartTile(
                      key: ValueKey(item.product.id),
                      item: item,
                      currency: currency,
                      onRemove: () => onRemoveFromCart(index),
                      onIncrement: () => onUpdateQuantity(index, item.quantity + 1),
                      onDecrement: () => onUpdateQuantity(index, item.quantity - 1),
                      onQuantityEdited: (qty) => onUpdateQuantity(index, qty),
                    );
                  },
                ),
              ],
            ],
          ),
        ),

        // Pinned footer at the bottom
        if (lineItems.isNotEmpty)
          Align(
            alignment: isLarge ? Alignment.bottomRight : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: footerMaxWidth.isInfinite ? screenWidth : footerMaxWidth,
              ),
              child: InlineCartFooter(
                grandTotal: grandTotal,
                totalItems: totalItems,
                currency: currency,
                onSave: onSave,
                elevated: isLarge,
              ),
            ),
          ),
      ],
    );
  }
}
