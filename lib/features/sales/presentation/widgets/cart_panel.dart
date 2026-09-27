import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/components/buttons/app_button.dart';
import '../../../../design_system/theme/theme_extensions.dart';

import '../../domain/sales_models.dart';

/// Cart panel showing line items, totals, and actions.
/// Used as right pane on tablet and inside bottom sheet on phone.
class CartPanel extends StatelessWidget {
  /// Creates the cart panel.
  const CartPanel({
    super.key,
    required this.lineItems,
    required this.currency,
    required this.grandTotal,
    required this.totalItems,
    required this.onRemoveFromCart,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.onSave,
    this.showHeader = true,
  });

  final List<SaleLineItem> lineItems;
  final NumberFormat currency;
  final double grandTotal;
  final int totalItems;
  final ValueChanged<int> onRemoveFromCart;
  final void Function(int index, int quantity) onUpdateQuantity;
  final VoidCallback onClearCart;
  final VoidCallback? onSave;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Cart header
        if (showHeader)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
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
                  size: 20,
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
                if (lineItems.isNotEmpty)
                  Badge(
                    label: Text('$totalItems'),
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                  ),
                const Spacer(),
                if (lineItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: onClearCart,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),

        // Line items
        Expanded(
          child: lineItems.isEmpty
              ? _EmptyCart()
              : _CartLineItems(
                  lineItems: lineItems,
                  currency: currency,
                  onRemove: onRemoveFromCart,
                  onUpdateQuantity: onUpdateQuantity,
                ),
        ),

        // Footer with total and pay button
        _CartFooter(
          grandTotal: grandTotal,
          totalItems: totalItems,
          currency: currency,
          onSave: onSave,
        ),
      ],
    );
  }
}

/// Empty cart placeholder.
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: spacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            SizedBox(height: spacing.md),
            Text(
              'Cart is empty',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Search or tap a product to add it',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of cart line items.
class _CartLineItems extends StatelessWidget {
  const _CartLineItems({
    required this.lineItems,
    required this.currency,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  final List<SaleLineItem> lineItems;
  final NumberFormat currency;
  final ValueChanged<int> onRemove;
  final void Function(int index, int quantity) onUpdateQuantity;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: lineItems.length,
      itemBuilder: (context, index) {
        final item = lineItems[index];
        return _CartLineItemTile(
          item: item,
          currency: currency,
          onRemove: () => onRemove(index),
          onIncrement: () => onUpdateQuantity(index, item.quantity + 1),
          onDecrement: () => onUpdateQuantity(index, item.quantity - 1),
        );
      },
    );
  }
}

/// Single cart line item — card-style, works well at any width.
class _CartLineItemTile extends StatelessWidget {
  const _CartLineItemTile({
    required this.item,
    required this.currency,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final SaleLineItem item;
  final NumberFormat currency;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: spacing.xl),
        color: colorScheme.errorContainer,
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    '${currency.format(item.product.price)} each',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.sm),

            // Quantity controls
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(spacing.sm),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: item.quantity <= 1
                        ? Icons.delete_outline
                        : Icons.remove,
                    onPressed: onDecrement,
                    color: item.quantity <= 1 ? colorScheme.error : null,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onPressed: onIncrement,
                  ),
                ],
              ),
            ),

            SizedBox(width: spacing.md),

            // Line total
            SizedBox(
              width: 80,
              child: Text(
                currency.format(item.total),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity stepper button.
class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Cart footer with total and save button.
class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.grandTotal,
    required this.totalItems,
    required this.currency,
    required this.onSave,
  });

  final double grandTotal;
  final int totalItems;
  final NumberFormat currency;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalItems item${totalItems == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      currency.format(grandTotal),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            // Pay button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Pay ${currency.format(grandTotal)}',
                icon: Icons.payment,
                onPressed: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
